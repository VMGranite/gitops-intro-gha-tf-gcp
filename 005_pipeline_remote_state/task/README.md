# 005 — Connect the Pipeline to GCP

**Goal:** give `infra/` a real GCS backend, and give the CI pipeline
from [004_basic_pipeline](../004_basic_pipeline) the ability to
actually authenticate to GCP and reach it — using the trust
relationship you built in
[003_gcp_github_trust](../003_gcp_github_trust), not a stored secret.

[Visit the Official google-github-actions/auth Action Here](https://github.com/google-github-actions/auth)

This is the exercise where `terraform init` in CI stops being purely
offline. Once `infra/main.tf` has a real `backend "gcs"` block,
`init` has to actually reach that bucket to configure the backend —
which means the workflow needs GCP credentials *before* `init` runs,
not just before `apply`.

## Vocabulary

- **`permissions: id-token: write`** — a workflow (or job) has to
  explicitly opt in to being allowed to request an OIDC token at all.
  Without this line, `google-github-actions/auth` fails before it even
  reaches GCP — GitHub itself refuses to mint the token.
- **ADC (Application Default Credentials)** — the well-known local
  location tools look for credentials by default, without you passing
  them explicitly. `google-github-actions/auth` writes short-lived
  credentials here on the runner; Terraform's `google` provider (and
  `gcloud`, if you used it) both pick them up automatically — you
  never reference them directly in your own config.

## Tasks

1. Copy this exercise's starting files over `infra/` and `.github/` at
   the repo root — both paths below already match their repo-root
   destination exactly, and both build directly on 004's solution, so
   this overwrites those files rather than merging by hand:
   ```bash
   cp -r 005_pipeline_remote_state/task/infra/. ./infra/
   cp -r 005_pipeline_remote_state/task/.github/. ./.github/
   ```
2. In `infra/main.tf`, fill in the `backend "gcs"` block's `TODO`s:
   - `bucket` — the literal state bucket name from
     [002_remote_state](../002_remote_state) (can't be a variable —
     same evaluation-order reason as always).
   - `prefix` — `"terraform-course/pipeline"`. This is a new prefix,
     separate from `002`'s own — `infra/`'s state lives on its own
     from here on.
3. In the copy you just created at `.github/workflows/terraform.yml`
   (repo root — not the template still under
   `005_pipeline_remote_state/task/`), fill in the `TODO`s:
   - The `permissions:` block.
   - The **Authenticate to Google Cloud** step, using
     `google-github-actions/auth` with the provider resource name and
     service account email you recorded at the end of `003`.
4. Branch, commit, push, open a PR — same loop as always. Watch the
   **Checks** tab: `init` should now show it successfully configured
   the `gcs` backend, not just downloaded providers.
5. Merge, then confirm state actually landed in the bucket:
   ```bash
   gcloud storage ls gs://YOUR_PROJECT_ID-tf-state/terraform-course/pipeline/
   ```

## Success criteria

The workflow's `terraform init` step succeeds and its log shows
`Successfully configured the backend "gcs"!` — and a state file exists
under `terraform-course/pipeline/` in your bucket, created entirely by
CI, never by a local `terraform init` on your own machine.

## Pro-tips

- Notice neither the provider resource name nor the service account
  email needs to be a GitHub **secret** — neither one is sensitive on
  its own; both are meaningless to anyone without also passing 003's
  attribute-condition and IAM-binding checks. That's the actual payoff
  of WIF over a downloaded key. [011_secrets](../011_secrets) covers
  what genuinely does need secret treatment in a pipeline.
- If `auth` fails with something like `Permission
  'iam.serviceAccounts.getAccessToken' denied`, re-check
  [003](../003_gcp_github_trust) Part 4 — the IAM binding has to match
  your exact `owner/repo`, and a typo there fails silently until this
  exact step.
- If `auth` fails before even reaching GCP, you almost certainly
  forgot the `permissions:` block — that's a GitHub-side check, not a
  GCP-side one.
- Step order matters: authentication has to happen **before**
  `terraform init` in the steps list. GitHub Actions runs steps
  top-to-bottom within a job; nothing runs them out of order for you.
