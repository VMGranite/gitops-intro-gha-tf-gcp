# 009 — Least-Privilege IAM for the CI Service Account

**Goal:** replace the CI service account's `Editor` role (granted in
[003_gcp_github_trust](../003_gcp_github_trust)) with a minimal set of
roles scoped to exactly what `infra/` actually manages — a VM and a
state bucket, nothing else — then prove the pipeline still works and
confirm the broader access is genuinely gone, not just unused.

## Why this was left broad until now

003's Pro-tips already flagged this trade-off: `Editor` was granted
there so the course didn't send you back to IAM every time a new
exercise introduced a new resource type. Now that `infra/` has settled
into what it actually manages — 007's VM, plus the state bucket from
002 — that trade-off isn't worth keeping. `Editor` can create, modify,
or delete almost anything in the project; the CI service account only
ever needs a small slice of that.

This is the same principle as
[008_pipeline_only_apply](../008_pipeline_only_apply), aimed at the
other identity: 008 restricted what *you* can do locally; this
restricts what *the pipeline itself* can do, so a mistake in
`infra/main.tf` — or a compromised workflow — can't reach outside the
boundary of what this course's `infra/` is actually supposed to touch.

## Tasks

1. **Work out the minimum roles.** `infra/` needs to:
   - Create, read, update, and delete `google_compute_instance`
     resources — `roles/compute.instanceAdmin.v1`.
   - Read and write Terraform state objects in the state bucket —
     `roles/storage.objectAdmin`, scoped to just that bucket, not the
     whole project.
2. **Remove the broad grant:** **IAM & Admin → IAM** → find
   `github-actions-ci@...` → edit its role list → remove **Editor**.
3. **Grant `compute.instanceAdmin.v1` at the project level:**
   **IAM & Admin → IAM → Grant Access** → principal
   `github-actions-ci@...` → role **Compute Instance Admin (v1)**.
4. **Grant `storage.objectAdmin` scoped to just the state bucket** —
   this time from the bucket's own page, not the project IAM page:
   **Cloud Storage → your state bucket → Permissions → Grant Access**
   → principal `github-actions-ci@...` → role **Storage Object
   Admin**.
5. **Prove it still works:** push a small change to the VM (e.g. a
   label) through the normal PR loop. Confirm `plan` and `apply` both
   succeed exactly as before.
6. **Prove it's actually narrower:** temporarily add a resource these
   two roles don't cover — e.g. a brand-new `google_storage_bucket`
   (not the state bucket) — to `infra/main.tf`, push it through a PR,
   and watch `apply` fail with `PERMISSION_DENIED` naming a
   `storage.buckets.create`-type permission. Then remove it again —
   `git revert` the commit, same mechanism as
   [011_rollback_revert](../011_rollback_revert) if you've already
   done that exercise.

## Success criteria

The CI service account's IAM entry shows `Compute Instance Admin (v1)`
(project-scoped) and `Storage Object Admin` (bucket-scoped) — no
`Editor` anywhere. A normal VM change still applies successfully
through the pipeline. A resource type outside that scope fails to
apply, with a `PERMISSION_DENIED` naming a permission neither role
grants.

## Pro-tips

- This scope is only correct for *this* `infra/`, *today*. Every later
  exercise that adds a genuinely new resource type needs you to come
  back here and extend it — this is the trade-off 003 chose to avoid
  until now, made concrete.
- Bucket-scoped IAM only works because
  [002_remote_state](../002_remote_state) enabled **Uniform
  bucket-level access** when the bucket was created — without it, this
  grant wouldn't be available the same way.
- Don't skip removing the test resource from Task 6 — either revert
  its commit or delete it and push a fix. Leaving it in
  `infra/main.tf` unapplied just leaves a permanent `plan` diff nobody
  resolves.

## Next

[010_peer_review](../010_peer_review) moves to a shared class repo —
its Part 0 sets up a brand-new WIF trust and service account for that
shared project. Consider granting it these same two scoped roles from
the start instead of `Editor`, now that you know what to grant and
why.
