# 011 — Secrets in GitHub Actions

**Goal:** give the pipeline a genuinely sensitive value — a webhook
URL that posts a message on every successful `apply` — the right way:
a GitHub **environment**, scoped secrets, and a required-reviewer gate
that pauses `apply` for a second approval even after the PR itself is
merged.

Contrast this with [005_pipeline_remote_state](../005_pipeline_remote_state):
the WIF provider resource name and service account email there were
never secrets, because knowing them grants nothing without also
passing 003's repo-scoped checks. A webhook URL is different — anyone
who has it can post to it. This is what secret treatment is actually
for.

## Vocabulary

- **Repository secret** — a value stored encrypted at the repo level,
  available to every workflow in the repo via `secrets.NAME`. Never
  logged, never visible in the UI once saved (not even to you).
- **Environment** — a named deployment target (`production`, `staging`,
  or here, one per student) that a job can declare with
  `environment: NAME`. Environments can have their own secrets
  (visible only to jobs that declare that environment) and their own
  **protection rules**.
- **Required reviewers** — a protection rule on an environment: a job
  targeting that environment doesn't run immediately, even after
  triggering — it waits in a pending state until a specified person
  approves it, in the Actions UI, separately from any PR approval.
- **`vars` vs `secrets`** — GitHub Actions also has a `vars.NAME`
  context for **non-secret** configuration (visible in logs, listed in
  the UI) — that's what 005's provider name and SA email should
  arguably use instead of being hardcoded literals, if you want to
  explore it further. This exercise is only about the `secrets`
  context, that being the actual new material.

## Tasks

1. Get a test webhook URL — [webhook.site](https://webhook.site) gives
   you one instantly, no signup, and shows every request it receives
   live in your browser. Use that, or a real Slack/Discord incoming
   webhook if you have one.
2. Create your own environment: **Settings → Environments → New
   environment**, named `YOUR_NAME-prod`.
3. On that environment's page:
   - Under **Deployment protection rules**, check **Required
     reviewers** and add a classmate (or yourself, to test solo).
   - Under **Environment secrets**, add `NOTIFY_WEBHOOK_URL` with your
     webhook URL from step 1.
4. Edit your own `.github/workflows/YOUR_NAME-terraform.yml` — the
   file already at the shared repo's **root**, the one you created in
   [009_peer_review](../009_peer_review) — on the `apply` job:
   - Add `environment: YOUR_NAME-prod` at the job level (a sibling of
     `runs-on:`, `if:`, `defaults:`). This is what links the job to
     the environment's protection rules and makes its secret
     available.
   - Add a final step, after `terraform apply`:
     ```yaml
           - name: Notify on successful apply
             run: |
               curl -X POST -H "Content-Type: application/json" \
                 -d "{\"text\": \"infra updated by ${{ github.actor }}\"}" \
                 "${{ secrets.NOTIFY_WEBHOOK_URL }}"
     ```
5. Branch, commit, push, open a PR for this workflow change itself,
   get it reviewed, merge.
6. Make any small change in your `infra/` to actually trigger `apply`
   (or re-run the workflow manually). Watch the **Actions** tab: the
   `apply` job should now sit in a **Waiting** state.
7. As the reviewer you named in step 3, open the run and click
   **Review deployments** → **Approve and deploy**. Only now does
   `apply` actually run.
8. Confirm the webhook fired — check webhook.site (or your Slack
   channel) for the request.

## Success criteria

`apply` visibly pauses for a second, separate approval after PR merge
— not just the PR review from
[009_peer_review](../009_peer_review) — and a request lands at your
webhook URL only after that approval.

## Pro-tips

- If `apply` runs immediately instead of waiting, double-check
  `environment:` is actually set on the **job**, not just referenced
  somewhere in a step — that's the one line that turns the protection
  rule on.
- Never echo a secret directly (`run: echo ${{ secrets.NOTIFY_WEBHOOK_URL }}`)
  — GitHub redacts *known* secret values from logs automatically, but
  only once they've been referenced as `secrets.X` in that run; a typo
  that leaks part of it, or a secret embedded inside other output, can
  still slip through.
- A required-reviewer gate and a PR-approval requirement are two
  independent checkpoints, on purpose — a PR review checks the *code*;
  a deployment approval checks *whether now is actually a good time to
  ship it*. Real teams use these for different reasons (e.g. a
  freeze window), even when the same person satisfies both.
