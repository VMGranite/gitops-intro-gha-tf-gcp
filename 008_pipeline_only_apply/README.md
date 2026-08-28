# 008 — Restrict `apply` to the Pipeline

**Goal:** make "a human never runs `terraform apply` against shared
infrastructure" an enforced technical control instead of just a
habit, using a GCP IAM Deny policy. `terraform plan` stays available
locally; only `apply` gets blocked, and only for you.

[Visit the Official IAM Deny Policies Documentation Here](https://cloud.google.com/iam/docs/deny-access)

## Why `plan` stays allowed but `apply` doesn't

`terraform plan` never changes anything in GCP — it only reads: the
current state of each resource, and the state file itself.
`terraform apply` is what actually calls the create/update/delete
APIs. Those are different permissions, which means you can deny
exactly one without touching the other: deny the *mutating*
permissions on the resource types `infra/` manages, for your own
account specifically, and leave every *read* permission alone.

The CI service account is untouched by this: a Deny policy only
affects the principals explicitly listed on it, and you'll list only
yourself — not `github-actions-ci@...`. The pipeline's `apply` keeps
working exactly as it does today; only your own laptop loses the
ability.

## Vocabulary

- **IAM Deny policy** — a rule that blocks specific permissions for
  specific principals, no matter what any `Allow` role grants them
  elsewhere. This is different from simply not granting a role — you
  very likely have `Owner` or `Editor` on this project (from creating
  it), which would otherwise let you do anything; a Deny policy is the
  one mechanism that overrides that.
- **Denied principals** — who the deny applies to. You'll list your
  own account, and nothing else.
- **Denied permissions** — exact permission *strings* being blocked
  (e.g. `compute.instances.create`), not a role. Picking permissions
  individually, rather than denying a whole role, is what lets you
  block writes without also blocking the reads `plan` needs.

## Tasks

1. In the [console.cloud.google.com](https://console.cloud.google.com)
   search bar, go to **IAM & Admin** → **Deny**.
   - If this option is missing or greyed out, you need the **Deny
     Administrator** role — project **Owner** already includes it;
     double-check you're looking at the right project.
2. Click **Create Deny Policy**.
3. **Policy name:** `no-local-apply`. Leave the scope as this project.
4. **Denied principals:** add your own Google account — the one you
   use for `gcloud auth application-default login`. **Not**
   `github-actions-ci@...`.
5. **Denied permissions:** search for and add each of these
   individually — these are exact permission strings, not a role:
   - `compute.instances.create`
   - `compute.instances.delete`
   - `compute.instances.update`
   - `compute.instances.setMetadata`
6. Leave **Exception principals** and **Condition** both empty.
7. Click **Create**.

## Success criteria

1. From `infra/`, locally: `terraform plan` still succeeds and shows a
   correct plan.
2. From `infra/`, locally: `terraform apply` fails with a
   `PERMISSION_DENIED` error naming one of the permissions above —
   even though you're the project's Owner.
3. Push the same change through a PR instead — the pipeline's `apply`
   (running as `github-actions-ci@...`) still succeeds.

## Pro-tips

- **Always leave yourself an escape hatch.** Before creating the
  policy, know how to remove it: **IAM & Admin** → **Deny** → open
  `no-local-apply` → **Delete**. Deny policies are powerful exactly
  because nothing overrides them — including, if you're not careful,
  your own ability to fix a mistake. This exercise denies four narrow,
  specific permissions for exactly that reason; resist the urge to
  "just deny the whole Editor role" here.
- If a local `apply` unexpectedly *succeeds*, some permission it used
  isn't on your denied list — different VM fields map to different
  permissions (e.g. changing `machine_type` uses
  `compute.instances.setMachineType`, not `update`). Check what
  actually changed, add the matching permission to the policy, and
  confirm with another attempt — then revert or clean up the stray
  change.
- This only restricts *compute instance* writes, since that's what
  `infra/` manages so far. If `infra/` grows to manage other resource
  types later, their equivalent mutating permissions need denying too
  — this doesn't generalize on its own.
- For genuinely complete lockdown, the state bucket itself should also
  deny direct object writes to your own account (scoped to the bucket,
  not the project). Left as a stretch goal here — `storage.objects.get`
  has to stay allowed for `plan` to work, and it's easy to over-scope
  a bucket-level deny by accident.

## Next

[009_least_privilege_service_account](../009_least_privilege_service_account)
does the equivalent narrowing for the *pipeline's* identity, not
yours — the CI service account has been running as `Editor` since
[003](../003_gcp_github_trust); this is where that gets tightened up.
After that, [010_peer_review](../010_peer_review) moves to a shared
class repo — now that a human genuinely cannot bypass the pipeline,
review on the PR isn't just courtesy, it's the only real checkpoint
before anything actually changes.
