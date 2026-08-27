# 006 — Plan on PR, Apply on Merge

**Goal:** split the single job from
[005_pipeline_remote_state](../005_pipeline_remote_state) into two:
one that runs `terraform plan` on every pull request, and one that
runs `terraform apply` only after a merge to `main`. This is the loop
[001_first_pull_request](../001_first_pull_request) told you was
coming — the actual mechanism behind "GitOps."

[Visit the Official Contexts Documentation Here](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs)

`infra/` doesn't have any resources in it yet — that's
[007_create_vm_end_to_end](../007_create_vm_end_to_end). This
exercise is entirely about the workflow's *shape*, not what it manages
yet. Don't be surprised when `plan` and `apply` both report "no
changes" — that's expected and correct.

This is a third new file, `006_pipeline.yml`, alongside
`004_pipeline.yml` and `005_pipeline.yml` — by the end of this
exercise every PR triggers three separate checks. Only this one ever
runs `apply`; the other two are still just `fmt`/`validate`/`init`
checks, same as they've always been, just running in parallel now.

## Vocabulary

- **`github.event_name`** — a built-in value telling you what
  triggered this run: `"pull_request"` or `"push"`, in this workflow.
  Available in any `if:` condition via `${{ github.event_name ==
  '...' }}`.
- **`github.ref`** — the branch or tag ref this run is on, e.g.
  `refs/heads/main`. Combined with `github.event_name`, this is how a
  job restricts itself to "push to `main` specifically," not any push.
- **Job-level `if:`** — a condition on a whole job, evaluated before
  any of its steps run. If it's false, the job is skipped entirely
  (shown as skipped, not failed, in the UI) — this is how `plan` and
  `apply` below stay in the same workflow file but never both run on
  the same trigger.
- **`-auto-approve`** — `terraform apply` normally pauses and asks you
  to type `yes`. There's no human at a keyboard in CI to answer that
  prompt, so `apply` needs this flag to proceed non-interactively.
  There's no equivalent flag for `plan` — it never needs approval,
  because it never changes anything.

## Tasks

1. From the **repo root**, add this exercise's new workflow file
   alongside the two already there:
   ```bash
   cp -r 006_plan_on_pr_apply_on_merge/task/.github/. ./.github/
   ```
   (`infra/` doesn't change in this exercise — nothing to copy there.)
2. In the new file at `.github/workflows/006_pipeline.yml` (repo root
   — not the template still under
   `006_plan_on_pr_apply_on_merge/task/`), the `plan` job's `TODO`s:
   - The `if:` condition — this job should run only on `pull_request`
     events.
   - The `terraform plan` step.
3. The `apply` job's `TODO`s:
   - The `if:` condition — this job should run only when
     `github.event_name` is `push` **and** `github.ref` is
     `refs/heads/main`.
   - The `terraform apply` step, non-interactively.
4. Branch, commit, push, open a PR. On the **Checks** tab, confirm you
   see the `plan` job run (showing "No changes") and the `apply` job
   listed as **skipped** — not run, not failed.
5. Merge the PR. Watch the **Actions** tab: a new workflow run starts
   for the push to `main`, and this time it's `apply` that runs while
   `plan` is skipped.

## Success criteria

Within the **`006 - Terraform CI`** check specifically (ignore `004`
and `005`'s, which behave exactly as before): two workflow runs total,
with opposite jobs skipped in each — on the PR, `plan` ran and `apply`
was skipped; after merge, `apply` ran and `plan` was skipped. Never
both, never neither.

## Pro-tips

- A subtle correctness gap in this exact setup: the `apply` job
  re-runs `terraform plan` internally (implicitly, as part of
  `apply`) against whatever `main` looks like *at merge time* — which
  is normally identical to what you reviewed on the PR, but isn't
  *guaranteed* to be if something else changed the underlying GCP
  resources in between. Production pipelines often close this gap by
  saving the PR's plan as a file (`terraform plan -out=tfplan`),
  uploading it as a workflow artifact, and having the `apply` job
  download and apply that *exact* file (`terraform apply tfplan`)
  instead of computing a fresh plan. Worth trying once you're
  comfortable with the basics here.
- If `apply` shows as **failed** instead of **skipped** on your PR's
  workflow run, your `if:` condition is wrong somewhere, not your
  Terraform — go back and check the exact `github.event_name`/
  `github.ref` values first.
