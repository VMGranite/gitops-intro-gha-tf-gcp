# 015 — A Policy Gate (Optional)

**Goal:** add an automated check that can block a merge for reasons
`terraform validate` doesn't catch — a rule about what your
infrastructure is *allowed* to look like, not just whether it's
syntactically valid. This is optional and more open-ended than earlier
exercises.

`terraform validate` (since
[004_basic_pipeline](../004_basic_pipeline)) only checks internal
consistency — it has no opinion on whether a VM should be
publicly reachable, or which machine types are acceptable, or whether
every resource has required labels. That's what a policy tool adds.

## Pick a tool

- [tflint](https://github.com/terraform-linters/tflint) — closer to a
  linter: catches provider-specific mistakes and style issues, easy to
  add, minimal configuration required to get started.
- [Checkov](https://www.checkov.io/) — a dedicated security/compliance
  policy scanner, with hundreds of built-in rules (e.g. "no world-open
  firewall rules," "disks should be encrypted") already written for
  you — heavier, but you write little to no policy code yourself to
  get real value.

Either is a reasonable choice for this exercise; Checkov is the faster
path to a rule that actually catches something interesting in `infra/`.

## Tasks (self-directed)

1. Add a new job (or step, in the existing `plan` job) to your
   workflow that runs your chosen tool against
   `students/YOUR_NAME/infra/` — most have a ready-made GitHub Action
   (e.g. `bridgecrewio/checkov-action`) so this is usually a `uses:`
   step, not a from-scratch script.
2. Make the job fail the check when the tool finds a violation —
   this is normally the tool's default behavior; confirm it, rather
   than assuming.
3. Add this new check to branch protection's required status checks
   (**Settings → Branches**), the same way `plan` was added in
   [010_peer_review](../010_peer_review) Part 0.
4. Prove it works both ways: write a change that should **pass** (e.g.
   a well-formed VM) and one that should **fail** (e.g. a firewall
   rule open to `0.0.0.0/0`) and confirm the check behaves correctly
   on each.

## Success criteria

A PR containing a real policy violation shows a failing status check
and is blocked from merging by branch protection — not just a warning
in a log somewhere, an actual enforced gate, the same way an
unreviewed PR is blocked.

## Discussion question

`terraform validate`, the `plan` check, and this policy check are
three different gates in the same pipeline, catching three different
kinds of problems. What's the fourth kind of problem none of them
catch — the kind only [010_peer_review](../010_peer_review)'s human
reviewer is positioned to catch?
