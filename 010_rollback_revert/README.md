# 010 — Rollback via `git revert`

**Goal:** make a change, decide it was a mistake, and undo it the
GitOps way — a new commit that reverses the old one, going through the
exact same PR/plan/review/merge/apply loop as any other change. Not
`terraform destroy`, not editing history, not SSHing in to fix it by
hand.

This continues in the shared repo from
[009_peer_review](../009_peer_review), inside your own
`students/YOUR_NAME/infra/`.

## Why not just fix it by hand, or rewrite history?

Two tempting shortcuts, both wrong here:

- **Fixing it by hand** (Console, `gcloud`, SSH) — this is exactly the
  "clickops" drift [008_pipeline_only_apply](../008_pipeline_only_apply)
  makes structurally impossible for you now anyway, but even without
  that: git would still say the bad config is correct, so the next
  `apply` from `main` would silently undo your manual fix.
- **`git reset` / force-push to rewrite history** — `main` is shared
  and protected; rewriting a commit history your teammates and CI have
  already built on is disruptive and, with branch protection on,
  likely blocked outright. It also erases the record that a mistake
  happened at all.

`git revert` creates a **new** commit that's the exact inverse of an
old one. History stays intact and honest — the mistake and its
correction are both permanently visible — and the new commit goes
through review and CI exactly like anything else.

## Tasks

1. **Make a change** to your VM in `students/YOUR_NAME/infra/main.tf`
   — bump `machine_type` from `"e2-micro"` to `"e2-small"`. Branch,
   commit, push, open a PR, get it reviewed (same loop as
   [009](../009_peer_review)), merge. Confirm `apply` ran and the
   change took effect.
2. **Find the merge commit** on `main` that introduced this change:
   ```bash
   git log --oneline -5
   ```
3. **Revert it**, on a new branch (branch protection applies to
   reverts too — this doesn't skip the process):
   ```bash
   git checkout main
   git pull
   git checkout -b YOUR_NAME/revert-machine-type
   git revert -m 1 <merge-commit-sha>
   ```
   `-m 1` is only needed because you're reverting a *merge* commit,
   which has two parents (the PR branch and `main` before it) — it
   tells git which parent represents "the state to go back to."
   git opens an editor for the revert commit's message; the default
   (`Revert "..."`) is fine.
4. Push, open a PR for the revert. Notice the `plan` output — it
   should show your VM going back to `e2-micro`, the exact inverse of
   step 1's plan.
5. Get it reviewed and merged like any other PR. Confirm `apply` ran
   and the VM is back to `e2-micro`.

## Success criteria

`git log` on `main` shows **three** commits for this round-trip — the
original change, and the revert — not one commit edited or removed.
The VM ends up back at `e2-micro`, and both the original PR and the
revert PR are still visible in the repo's history and PR list.

## Pro-tips

- The same mechanism works for a change that **added** a resource, not
  just one that modified a field — revert the commit that added a
  `resource` block, and the next `plan` shows it staged for
  **deletion**, cleanly, through the pipeline. Rollback and
  destruction aren't different tools here; they're the same tool
  pointed at different commits.
- If `git revert` reports a conflict, it means something else changed
  the same lines since — resolve it exactly like the merge conflict
  practice back in
  [001_first_pull_request](../001_first_pull_request), then
  `git revert --continue`.
