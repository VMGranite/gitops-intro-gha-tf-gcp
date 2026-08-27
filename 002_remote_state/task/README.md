# 002 — Create Remote State Storage

**Goal:** create, by hand in the GCP Console, the bucket that will
hold Terraform state for every exercise in this course — then point
Terraform's backend at it.

[Visit the Official Terraform GCS Backend Documentation Here](https://developer.hashicorp.com/terraform/language/backend/gcs)

## Why the bucket comes first, by hand, in the Console

Terraform reads a `backend "gcs" { bucket = ... }` block before it
evaluates anything else in a config — there's no state yet at that
point to look a bucket name up *in*. So whatever bucket a backend
points at has to already exist, created some other way, before that
config's first `init`. Doing this one by hand in the Console — rather
than writing a Terraform config that creates its own state bucket —
also sidesteps a Terraform config managing its own critical dependency,
which is extra risk for something every later exercise in this course
relies on.

## Part 1 — Create the bucket (GCP Console)

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
   and confirm the correct project is selected in the project picker
   (top-left) — everything you create is scoped to whichever project
   is selected there.
2. Use the search bar at the top ("Search products and resources...")
   and type **Cloud Storage**, or go via the ☰ menu → **Cloud Storage**
   → **Buckets**.
3. Click **+ Create** (or **Create bucket**).
4. **Name your bucket:** `YOUR_PROJECT_ID-tf-state`. Bucket names are
   **globally unique across all of GCP**, not just your project —
   using your project ID guarantees that. Lowercase letters, numbers,
   and hyphens only.
5. **Choose where to store your data:** Location type **Region**,
   location `us-central1` (matches the region used elsewhere in this
   course).
6. **Choose a storage class:** leave the default (**Standard**).
7. **Choose how to control access to objects:** select **Uniform**
   (not "Fine-grained"). This gives the bucket one consistent IAM
   model instead of per-object permissions — this matters more once
   [003_gcp_github_trust](../../003_gcp_github_trust) grants GitHub
   Actions access to this same bucket.
8. **Choose how to protect object data:** turn on **Object versioning**.
   This keeps prior state file versions around, so a bad state write
   is recoverable instead of destructive. (If your Console shows this
   as a separate step after creation instead of during the wizard: open
   the bucket → **Protection** tab → **Object versioning** → **Enable**.)
9. Click **Create**.
10. Confirm: open the bucket → **Protection** tab → **Object
    versioning** should read **Enabled**.

Write the bucket name down. Starting with the `task/main.tf` below,
and in every exercise after this one, you'll type it as a **literal
string** into a `backend "gcs" { bucket = "..." }` block — it can't be
a variable (see "Why the bucket comes first" above; the same
evaluation-order constraint applies to every backend block, not just
this first one).

## Part 2 — Point Terraform at it

1. Edit `terraform.tfvars` with your real `project_id`.
2. Open `main.tf`. Add a `backend "gcs"` block inside the `terraform`
   block:
   - `bucket` — the literal bucket name you just created, e.g.
     `"your-project-id-tf-state"`.
   - `prefix` — `"terraform-course/002-remote-state"`. Every later
     exercise uses this same bucket with its own `prefix`, so each
     exercise's state stays separate inside one shared bucket.
3. Add a small `google_storage_bucket` resource — its own name, region
   scratch bucket, nothing important — just something for this
   exercise's state to actually track. See the Hints if you want to
   reuse a resource you already wrote in `gcp-infra-as-code`.
4. Run `terraform fmt`, `terraform init`, `terraform plan`, and
   `terraform apply`.

## Success criteria

`terraform apply` succeeds, and this exercise's state file — not a
local `terraform.tfstate` — shows up in the bucket:

```bash
gcloud storage ls gs://YOUR_PROJECT_ID-tf-state/terraform-course/002-remote-state/
```

(No local `terraform.tfstate` should appear in this folder at all —
unlike every exercise in `gcp-infra-as-code`, this config never used
local state even once.)

## Hints

- Do **not** run `terraform destroy` on the bucket itself — it isn't a
  Terraform resource in this config to begin with (you made it by
  hand in Part 1), so `destroy` only tears down the scratch resource
  inside it, which is exactly what you want.
- If `init` fails with a permissions error, double-check you're
  authenticated as yourself for now (`gcloud auth application-default
  login`, from `gcp-infra-as-code`'s `000_start_here`) —
  [003_gcp_github_trust](../../003_gcp_github_trust) is what gets
  *GitHub Actions* permission on this bucket; that's a separate
  identity from your own.
- If you get a "bucket name already in use" error back in Part 1,
  someone else — in the world, not just this class — already has that
  exact name. GCS bucket names are one global namespace. Double-check
  you used your actual project ID.
