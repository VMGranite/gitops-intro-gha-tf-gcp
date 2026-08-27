# 004 — A Basic GitHub Actions Pipeline

**Goal:** write a minimal GitHub Actions workflow that runs
`terraform fmt -check` and `terraform validate` on every push and pull
request — no GCP credentials involved yet.

[Visit the Official GitHub Actions Workflow Syntax Documentation Here](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)

This exercise deliberately keeps GCP out of it. `terraform validate`
checks that your configuration is internally consistent — types match,
required arguments are present, references resolve — entirely offline,
using only the provider's schema (downloaded from the public Terraform
registry; no GCP auth needed for that). Actually talking to GCP starts
in [005_pipeline_remote_state](../005_pipeline_remote_state), using
the trust relationship you built in
[003_gcp_github_trust](../003_gcp_github_trust).

## A new directory: `infra/`

Every exercise so far lived in its own numbered folder, run by hand
from your terminal. Starting now, one directory — `infra/`, at the
**repo root**, not inside this exercise's folder — is what your
GitHub Actions pipeline manages, and it stays around for the rest of
the course: 005 gives it a backend, 006 makes it plan/apply
automatically on its own, 007 adds a real VM to it. This exercise's
`task/infra/` is the starting point — copy it to the repo root to
begin.

Workflow files have the same constraint, for a different reason:
GitHub only runs workflows it finds in `.github/workflows/` at the
repo root — not in a subfolder. So this exercise's starter workflow
lives at `task/.github/workflows/004_pipeline.yml` — the exact same
path it needs at the repo root, just rooted inside
`004_basic_pipeline/` instead. Copying `task/.github` to the repo
root's `.github` (step 1 below) is what actually puts it where GitHub
will find and run it.

Each exercise's workflow file gets its own name — `004_pipeline.yml`
here, `005_pipeline.yml` next, and so on — instead of every exercise
overwriting one shared file. Nothing you build gets erased by the
next exercise; `.github/workflows/` accumulates one file per exercise,
same as the numbered folders themselves do. GitHub happily runs every
workflow file that matches a trigger, so once 005 and 006 exist
alongside this one, you'll see multiple checks on a single PR — that's
expected, not a bug; see 005's README for what that looks like.

## Vocabulary

- **Workflow** — a YAML file in `.github/workflows/` that defines
  automated jobs. Each file is one workflow.
- **Trigger (`on:`)** — what causes the workflow to run: a push, a
  pull request, a schedule, etc.
- **Job** — one unit of work, running on its own fresh virtual
  machine (a "runner"). A workflow can define multiple jobs.
- **Step** — one command or action inside a job, run in order, on the
  same runner.
- **Runner** — the virtual machine GitHub spins up to execute your
  job. `ubuntu-latest` is the default and what this course uses
  throughout.
- **Action** — a reusable, packaged step someone else wrote (e.g.
  `actions/checkout`) — referenced with `uses:` instead of you writing
  the underlying commands yourself.

## Tasks

1. From the repo root, copy this exercise's starting files into place —
   both paths below already match their repo-root destination exactly:
   ```bash
   cp -r 004_basic_pipeline/task/infra ./infra
   cp -r 004_basic_pipeline/task/.github ./.github
   ```
2. Edit `infra/terraform.tfvars` with your real `project_id`.
3. Open the copy you just created at
   `.github/workflows/004_pipeline.yml` (repo root — **not** the one
   still sitting under `004_basic_pipeline/task/`, which is only the
   template) and fill in the `TODO`s:
   - A trigger that runs on every push to `main` **and** every pull
     request, regardless of target branch.
   - Which runner to use.
   - The `actions/checkout` action, so the runner actually has your
     repo's files — nothing runs on a blank machine by default.
   - The `hashicorp/setup-terraform` action, so the `terraform` CLI
     exists on the runner at all.
   - The `fmt -check` and `validate` commands themselves.
4. Following the branch → commit → push → PR loop from
   [001_first_pull_request](../001_first_pull_request): branch, add
   both `infra/` and `.github/workflows/004_pipeline.yml`, commit,
   push, and open a PR.
5. On the PR, click the **Checks** tab (or the small status icon next
   to your latest commit) to watch the workflow run. Fix anything that
   fails, push again — the workflow reruns automatically on every new
   commit to the branch.
6. Merge once it passes.

## Success criteria

The **`004 - Terraform CI`** check shows a green check on your PR, and
the **Actions** tab in GitHub (top nav of the repo) shows a successful
run of it with both the `fmt` and `validate` steps completed.

## Pro-tips

- `terraform init` is already filled in for you in the starter file —
  it has to run before `validate` (Terraform needs the provider
  downloaded to know what a valid `google_compute_instance` block even
  looks like) but isn't itself a new concept here.
- `working-directory: infra` under `defaults.run` means every `run:`
  step in this job executes from inside `infra/` automatically — you
  don't need `cd infra &&` in every command.
- If the workflow doesn't appear at all under the **Actions** tab,
  double check the file is really at
  `.github/workflows/004_pipeline.yml` from the repo root, not nested
  under `004_basic_pipeline/`.
- Pin action versions (`actions/checkout@v4`, not just
  `actions/checkout`) — floating on whatever's "latest" means your
  pipeline's behavior can change under you without any change to your
  own files.
