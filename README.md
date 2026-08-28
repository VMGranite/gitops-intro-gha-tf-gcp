# Intro to GitOps: GitHub Actions + Terraform + GCP

This course assumes you already know Terraform basics — providers,
resources, variables, state. Nothing here re-teaches HCL syntax — the
new material is everything *around* Terraform: git, GitHub, GitHub
Actions, and the specific workflow ("GitOps") of using a pull request
as the thing that triggers infrastructure changes.

Start with [000_start_here](000_start_here) and
[001_first_pull_request](001_first_pull_request) — even if you've used
git before, they walk through the exact clone/branch/commit/push/PR/merge
sequence every later exercise assumes you can do without thinking
about it. If you've genuinely never touched git, do not skip them.

Each numbered exercise folder has two subfolders:

- **`task/`** — the README and starter code (with `TODO`s) you work
  from.
- **`solution/`** — a complete, working implementation. Try the
  exercise yourself first — the solution is there to check your work
  or unstick you, not to copy before attempting it.

Exercises that are pure setup/reading, or that build on files already
personalized to you in the shared repo (from
[010_peer_review](010_peer_review) onward, once your own
`students/YOUR_NAME/` folder and workflow exist), have a single
`README.md` with inline instructions instead of a `task/`/`solution/`
split — there's no single shared starting file left to copy from at
that point.

| # | Exercise | Concepts |
|---|---|---|
| [000_start_here](000_start_here) | Git & GitHub setup | `git config`, `gh auth login` |
| [001_first_pull_request](001_first_pull_request) | Git & GitOps fundamentals | branch, commit, push, PR, merge, merge conflicts |
| [002_remote_state](002_remote_state/task) | Create remote state storage | manual bucket creation in the GCP Console, `backend "gcs"` |
| [003_gcp_github_trust](003_gcp_github_trust) | Link GitHub Actions to GCP | Workload Identity Federation, manual/console setup |
| [004_basic_pipeline](004_basic_pipeline/task) | A basic GitHub Actions pipeline | workflow YAML, triggers, jobs/steps, runners |
| [005_pipeline_remote_state](005_pipeline_remote_state/task) | Connect the pipeline to GCP | WIF auth in CI, `terraform init` against the shared backend |
| [006_plan_on_pr_apply_on_merge](006_plan_on_pr_apply_on_merge/task) | The core GitOps loop | `pull_request` → `plan`, `push` to `main` → `apply` |
| [007_create_vm_end_to_end](007_create_vm_end_to_end/task) | Ship a VM through the loop | first real end-to-end PR → plan → merge → apply |
| [008_pipeline_only_apply](008_pipeline_only_apply) | Restrict `apply` to the pipeline | IAM Deny policies, `plan` vs. `apply` permissions |
| [009_least_privilege_service_account](009_least_privilege_service_account) | Least-privilege IAM for the CI service account | scoped roles, replacing `Editor` |
| [010_peer_review](010_peer_review) | Branch protection & peer review (team exercise) | required reviews, shared class repo, reviewing a `plan` diff |
| [011_rollback_revert](011_rollback_revert) | Rollback via `git revert` | git history as the rollback mechanism, not `terraform destroy` |
| [012_secrets](012_secrets) | Secrets in GitHub Actions | `secrets:` context, environment protection rules |
| [013_drift_detection](013_drift_detection) | Scheduled drift detection | `on: schedule`, plan-only jobs, alerting on drift |
| [014_environments](014_environments) (optional) | Promote dev → prod | per-environment state, promotion via PR |
| [015_policy_as_code](015_policy_as_code) (optional) | A policy gate | `tflint`/`checkov` as a required check |

## General setup

You'll need your own GCP project, with the `gcloud` CLI authenticated
locally (`gcloud auth application-default login`), and a GitHub
account. Exercises 000–009 are solo work against your own project.
[010_peer_review](010_peer_review) onward moves to a shared class
repo — that exercise explains the switch and what changes.
