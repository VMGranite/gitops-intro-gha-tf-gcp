# 010 — Branch Protection & Peer Review

**Goal:** move to a shared class repo where a real second person
reviews your `plan` output before your change can merge — and where
GitHub itself, not just courtesy, prevents merging without that
review.

Everything through [008_pipeline_only_apply](../008_pipeline_only_apply)
was solo: your own project, your own repo, your own review of your
own plan. Nothing enforced review even existed. This exercise adds
both the enforcement (branch protection) and the actual second person
(a partner from class).

## Part 0 — One-time setup (whoever is repo admin does this once)

This part is done by one person for the whole class — most likely
your instructor — not repeated by every student.

1. Create a new GitHub repo for the class and add every student as a
   collaborator (**Settings → Collaborators**).
2. Create a **new, shared GCP project** for this repo — separate from
   everyone's individual project from earlier exercises. Everyone's
   solo work stays exactly as it is; this is a fresh project just for
   the team phase.
3. In that shared project, repeat
   [002_remote_state](../002_remote_state) Part 1 exactly (create a
   state bucket by hand in the Console) and
   [003_gcp_github_trust](../003_gcp_github_trust) Parts 1–5 exactly
   (Workload Identity Federation), with one change: the attribute
   condition and the "Grant Access" scoping in Part 4 should match
   this **new shared repo**, not any individual student's fork.
4. **Branch protection** on `main` (**Settings → Branches → Add branch
   protection rule**):
   - Branch name pattern: `main`.
   - Check **Require a pull request before merging**, with
     **Require approvals** set to **1**.
   - Check **Require status checks to pass before merging**, and
     search for and select the `plan` check (it won't appear in the
     list until at least one workflow run has produced it once — come
     back and add it after the first PR in Part 1 below if it's
     missing now).
   - Save.
5. Share the shared bucket name and the WIF provider resource
   name/service account email from step 3 with the whole class.

## Part 1 — Bring your work into the shared repo

Everyone does this part individually, once:

1. Clone the shared repo.
2. Create `students/YOUR_NAME/infra/` and copy your own `infra/`
   `.tf` files into it (from your solo repo, as of
   [007_create_vm_end_to_end](../007_create_vm_end_to_end) or
   [008_pipeline_only_apply](../008_pipeline_only_apply)) — or start
   from `010_peer_review/template/infra/` if you'd rather begin clean.
   Either way, edit the `backend "gcs"` block:
   - `bucket` — the shared bucket from Part 0.
   - `prefix` — `"terraform-course/team/YOUR_NAME"`. This is a new,
     separate prefix from your solo pipeline's — nothing here touches
     your individual state.
3. From the **repo root** of the shared repo (not any exercise
   subfolder), copy the template to your own, uniquely-named workflow
   file — same `.github/workflows/` path every other exercise has used,
   just now with your name in the filename so it doesn't collide with
   a classmate's:
   ```bash
   cp 010_peer_review/template/.github/workflows/terraform-template.yml \
     .github/workflows/YOUR_NAME-terraform.yml
   ```
   Then edit your new copy at `.github/workflows/YOUR_NAME-terraform.yml`:
   - Both `paths:` filters (under `pull_request:` and `push:`) to
     `students/YOUR_NAME/infra/**`.
   - `working-directory` (two places) to `students/YOUR_NAME/infra`.
   - `workload_identity_provider` and `service_account` to the shared
     values from Part 0.

   Each student gets their **own** workflow file, scoped by `paths:`
   to their own folder only — so your PR's checks only ever plan/apply
   your own resources, never a classmate's, even though you're all in
   one repo with one shared `main`.
4. Branch, commit, push, open a PR. Confirm your `plan` job runs (and
   nobody else's does).

## Part 2 — The review loop

Pair up with a classmate — you review each other's next change, then
switch who's authoring for the round after.

1. **Author:** branch off `main`, make a small change inside your own
   `students/YOUR_NAME/infra/` (e.g. add a firewall rule, or change
   the VM's `machine_type`). Push, open a PR, and request your partner
   as a reviewer (the **Reviewers** panel on the PR page).
2. **Reviewer:** open the PR. Read the diff. Open the `plan` job's log
   and actually read what it says would change — this is the part
   that matters; approving without reading the plan defeats the point
   of this exercise. Leave at least one comment (a question is fine,
   it doesn't have to be a correction), then either **Approve** or
   **Request changes**.
3. **Author:** if changes were requested, push a fix commit and
   re-request review. Once approved and the `plan` check is green,
   merge.
4. Confirm `apply` ran (only in your own folder) and your change took
   effect.
5. Switch roles for a second round, so everyone both authors and
   reviews at least once.

## Success criteria

A merge you attempt **without** an approval is blocked by GitHub
itself (try it once, on purpose, to see the block) — and a real
comment thread exists on at least one PR from an actual reviewer, not
just yourself.

## Pro-tips

- If the **Merge** button is greyed out even after approval, check the
  `plan` check actually passed — branch protection here requires
  both, not either.
- The template's `plan` job posts the plan output as a PR comment
  (via `actions/github-script`), specifically so your reviewer doesn't
  have to dig into the Actions tab to see what would change — read
  through that script once; it's the one piece of this template that's
  given to you complete rather than left as a `TODO`, since it's
  plumbing, not the lesson.
- Nothing stops you from approving your own PR by disabling branch
  protection temporarily — which is exactly why this is a policy
  enforced by the repo admin, not something any one student controls.
