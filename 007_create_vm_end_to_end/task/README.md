# 007 — Ship a VM, End to End

**Goal:** use the pipeline you just built for something real — add a
VM to `infra/` through a real PR, watch `plan` show it in the Checks
tab, merge, and watch `apply` create it. No workflow changes this
time; this exercise is entirely about `infra/main.tf`.

Nothing here is new Terraform, only new *process*: this is the first
resource in this course that gets created by a pipeline instead of
your own `terraform apply`.

## Tasks

1. Copy this exercise's `infra/` over the repo root's (only `main.tf`
   changes — same pattern as always):
   ```bash
   cp -r 007_create_vm_end_to_end/task/infra/. ./infra/
   ```
2. In `infra/main.tf`, fill in the `google_compute_instance` block's
   `TODO`s:
   - `machine_type` — `"e2-micro"`.
   - `zone` — `"${var.region}-a"`.
   - The boot disk's image — `"debian-cloud/debian-12"`.
   - An `access_config {}` block inside `network_interface` — an empty
     block here is what gives the VM an ephemeral external IP, so you
     can actually reach it.
3. Add the `vm_external_ip` output.
4. Branch, commit, push, open a PR. You'll see three checks now
   (`004`, `005`, `006 - Terraform CI`) — `004` and `005` still just
   run `fmt`/`validate`/`init`; only `006`'s has `plan`/`apply` jobs.
5. On the **Checks** tab, open **`006 - Terraform CI`**'s `plan` job
   log — confirm it shows `1 to add, 0 to change, 0 to destroy` for
   the VM.
6. Merge. Watch `006 - Terraform CI`'s `apply` job create it.
7. Confirm, either way:
   ```bash
   gcloud compute instances list --filter="name~gitops-vm"
   ```
   or, locally, from `infra/` (this only *reads* state — it works
   fine even after later exercises restrict local `apply`):
   ```bash
   terraform init && terraform output vm_external_ip
   ```

## Success criteria

The VM exists in GCP, was created entirely by `006 - Terraform CI`'s
`apply` job (never by a local `terraform apply`), and
`terraform output vm_external_ip` returns a real IP address.

## Pro-tips

- Leave this VM running — later exercises build directly on it:
  [008_pipeline_only_apply](../008_pipeline_only_apply) locks down who
  can modify it, and [010_rollback_revert](../010_rollback_revert)
  changes and then un-changes it.
- Once [008_pipeline_only_apply](../008_pipeline_only_apply) is done,
  you won't be able to `terraform destroy` this locally anymore
  either — tearing it down at the end of the course will need to go
  through a PR too, same as creating it did.
- If `apply` fails with something like `Compute Engine API has not
  been used in this project`, the API just needs enabling — search
  **Compute Engine API** in the Console and click **Enable**. This is
  usually already on if you've created a VM in this project before.
