# 013 — Promote Dev → Prod (Optional)

**Goal:** run the same VM config against two separate environments —
`dev` and `prod` — with dev applying automatically on merge, and prod
requiring a deliberate, separate promotion step. This is optional and
more open-ended than earlier exercises: a recommended shape is given
below, but working out the exact implementation is the exercise.

## The idea

One set of `.tf` files, two environments, each with its own state and
its own VM — changed by promoting the *exact same, already-reviewed*
config from one to the other, not by writing it twice.

A workable structure:

- `students/YOUR_NAME/infra/` stays as your **dev** environment —
  unchanged from earlier exercises, still applying automatically on
  every merge to `main`, exactly as it does today.
- A new `students/YOUR_NAME/infra-prod/` holds the **same** resource
  definitions (consider a shared `.tf` file, or a small
  [module](https://developer.hashicorp.com/terraform/language/modules)
  both directories call, so you're not maintaining two copies by
  hand), with its own `backend "gcs"` `prefix` and its own
  `terraform.tfvars`.
- **Promotion** happens on a schedule or trigger of your choosing —
  two reasonable options:
  - A second workflow, triggered by `workflow_dispatch` only (no
    automatic trigger at all) — a human explicitly runs it when
    they've decided dev looks good.
  - Gate the prod `apply` job with the same `environment:` +
    required-reviewer mechanism from
    [011_secrets](../011_secrets), so promotion is "approve a pending
    deployment," not "run a different command."

## Questions worth answering as you build this

- If dev and prod are meant to be *identical* configuration, what's
  actually allowed to differ between them (machine size? region?
  nothing at all)? Where should that difference live — a `.tfvars`
  file per environment is one answer.
- What stops someone from applying directly to prod without ever going
  through dev first? Is that something you want to prevent structurally,
  or just by convention?
- [Visit the Official Terraform Workspaces Documentation Here](https://developer.hashicorp.com/terraform/language/state/workspaces)
  — workspaces are a different (and more built-in) way to run one
  config against multiple states than the separate-directories
  approach above. Worth comparing once you have one approach working.

## Success criteria

Self-directed: you should be able to make one change, see it applied
to dev automatically, and then — through a distinct, deliberate
action — promote that same change to prod, with prod's own state
showing it.
