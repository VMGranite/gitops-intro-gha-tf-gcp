# 012 — Scheduled Drift Detection

**Goal:** a workflow that runs on a schedule, does nothing but
`terraform plan`, and flags it when your VM's real state in GCP
disagrees with `main` — closing the loop on "git is the source of
truth" from way back in
[001_first_pull_request](../001_first_pull_request): reality is
*expected* to match git, and now something actually checks.

## Vocabulary

- **`on: schedule`** — a cron-syntax trigger (`cron: "0 * * * *"` =
  every hour, on the hour) that runs a workflow with no push or PR
  involved at all.
- **`workflow_dispatch`** — a manual trigger, adding a **Run workflow**
  button in the Actions UI. Adding this alongside `schedule` lets you
  test the workflow on demand instead of waiting for the next
  scheduled run.
- **`-detailed-exitcode`** — a flag for `terraform plan` that turns its
  normally-uniform exit code into a signal: `0` = no changes, `1` =
  an error, `2` = changes exist (drift). Without this flag, `plan`
  always exits `0` whether or not it found anything to change, which
  makes "did we find drift?" impossible to script against directly.

## Tasks

1. Create a new workflow file,
   `.github/workflows/YOUR_NAME-drift-detection.yml`:
   ```yaml
   name: Drift Detection - YOUR_NAME

   on:
     schedule:
       - cron: "0 * * * *"
     workflow_dispatch:

   permissions:
     contents: read
     id-token: write

   jobs:
     drift-check:
       runs-on: ubuntu-latest
       defaults:
         run:
           working-directory: students/YOUR_NAME/infra
       steps:
         - name: Checkout code
           uses: actions/checkout@v4

         - name: Authenticate to Google Cloud
           uses: google-github-actions/auth@v2
           with:
             workload_identity_provider: "YOUR_PROVIDER_RESOURCE_NAME"
             service_account: "github-actions-ci@YOUR_SHARED_PROJECT_ID.iam.gserviceaccount.com"

         - name: Set up Terraform
           uses: hashicorp/setup-terraform@v3
           with:
             terraform_version: "1.7.5"

         - name: Terraform init
           run: terraform init

         - name: Terraform plan (drift check)
           run: terraform plan -detailed-exitcode
   ```
2. Branch, commit, push, PR, review, merge this new file — same loop
   as always, since it's still just a file change to the repo.
3. **Cause some drift on purpose:** in the Console, manually add a
   label to your VM (**Compute Engine → VM instances → your VM →
   Edit → Labels**), or change something small by hand — anything
   `main` doesn't know about.
4. Go to the **Actions** tab, select **Drift Detection - YOUR_NAME**,
   and click **Run workflow** (`workflow_dispatch` — don't wait for the
   hourly schedule).
5. Confirm the run **fails** — `-detailed-exitcode`'s `2` is treated as
   a failing exit code, so a drifted run shows red, distinct from a
   clean run showing green.
6. **Reconcile it**, either direction:
   - If the manual change should stick, open a PR updating `main` to
     match it (accept the drift into git).
   - If it shouldn't, do nothing — the next real `apply` (from any
     other merged change, or by manually re-running the main
     `terraform.yml`'s `apply` job) puts it back, since `main` never
     changed.

## Success criteria

A clean run of the drift-check workflow shows green with "No changes."
A run after your manual edit shows red, and the log names exactly what
drifted — the VM attribute you changed by hand.

## Pro-tips

- An hourly schedule is aggressive for a course exercise — real teams
  more commonly run this daily or a few times a day. `0 * * * *` here
  is chosen so you don't have to wait long while testing; tune it
  down once you've confirmed it works.
- This workflow never runs `apply` — on purpose. Detecting drift and
  fixing it are deliberately two different actions here, so a false
  positive (a scheduled job misfiring) can never silently change
  anything on its own.
- Combine this with [011_secrets](../011_secrets)'s webhook: add the
  same notify step here, conditioned on the plan step's outcome, so
  drift pages someone instead of only showing up if someone happens to
  check the Actions tab.
