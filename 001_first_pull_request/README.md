# 001 — Your First Pull Request

**Goal:** practice the full git/GitHub loop — branch, commit, push,
PR, merge, and a merge conflict — before it matters, then connect it
to what "GitOps" actually means.

This continues directly from [000_start_here](../000_start_here) —
make sure you've cloned the repo and run `gh auth login` first.

## 1. The core loop: branch → commit → push → PR → merge

Do this once now, on a throwaway change, so the sequence is muscle
memory before it matters:

1. **Branch off `main`:**
   ```bash
   git checkout -b YOUR_NAME/practice
   ```
   This creates a new branch starting from your current position and
   switches to it. Nothing about `main` has changed yet — you're on an
   independent line of commits.
2. **Make a change and look at it:**
   ```bash
   echo "hello from YOUR_NAME" >> 001_first_pull_request/scratch.txt
   git status
   git diff
   ```
   `status` shows which files changed; `diff` shows exactly what
   changed, line by line. Get in the habit of reading `diff` before
   every commit — it's the fastest way to catch a mistake before it's
   recorded.
3. **Stage and commit:**
   ```bash
   git add 001_first_pull_request/scratch.txt
   git commit -m "Practice commit from YOUR_NAME"
   ```
   `add` moves a change into the "staging area" — the set of changes
   that will go into the *next* commit. This two-step (`add` then
   `commit`) is git's way of letting you commit only some of your
   changes, not all of them, on purpose.
4. **Push your branch to GitHub:**
   ```bash
   git push -u origin YOUR_NAME/practice
   ```
   Your branch now exists on GitHub too, not just on your machine.
   `-u` remembers this mapping so future `git push` on this branch
   needs no arguments.
5. **Open a pull request:** GitHub will print a URL after the push —
   follow it, or go to the repo on GitHub and click "Compare & pull
   request." Give it a title, leave a comment, open it.
6. **Merge it:** click "Merge pull request" on GitHub. Your change is
   now part of `main`'s history.
7. **Sync back up and clean up:**
   ```bash
   git checkout main
   git pull
   git branch -d YOUR_NAME/practice
   ```
   `pull` fetches `main`'s new state (including the merge you just
   did) from GitHub into your local copy. `-d` deletes the now-merged
   branch locally — GitHub usually offers to delete the remote copy
   for you after a merge.

## 2. A merge conflict, on purpose

Conflicts are the part that intimidates people who are new to git —
doing one deliberately, once, in a low-stakes file, takes the fear out
of it.

1. On `main`, edit `001_first_pull_request/scratch.txt` and commit
   directly (just this once — normally you'd branch first):
   ```bash
   echo "line from main" >> 001_first_pull_request/scratch.txt
   git add 001_first_pull_request/scratch.txt
   git commit -m "Edit from main"
   ```
2. Create a branch from *before* that commit and edit the same line:
   ```bash
   git checkout -b YOUR_NAME/conflict-practice HEAD~1
   echo "line from branch" >> 001_first_pull_request/scratch.txt
   git add 001_first_pull_request/scratch.txt
   git commit -m "Conflicting edit from branch"
   ```
3. Try to merge `main` into your branch:
   ```bash
   git merge main
   ```
   Git will stop and tell you `scratch.txt` conflicts. Open it — git
   has inserted markers:
   ```
   <<<<<<< HEAD
   line from branch
   =======
   line from main
   >>>>>>> main
   ```
   Everything between `<<<<<<<` and `=======` is your branch's
   version; everything between `=======` and `>>>>>>>` is `main`'s.
   Edit the file by hand to keep whichever content is correct (or
   both), delete the marker lines, then:
   ```bash
   git add 001_first_pull_request/scratch.txt
   git commit
   ```
   That commit (with no `-m`) completes the merge. A conflict is never
   git guessing wrong — it's git refusing to guess at all, and asking
   you to decide.
4. Clean up — you don't need to push or PR this practice branch:
   ```bash
   git checkout main
   git branch -D YOUR_NAME/conflict-practice
   ```

## Next

[002_remote_state](../002_remote_state) is next — you'll start
building the actual pipeline this branch/commit/push/PR/merge loop is
for.
