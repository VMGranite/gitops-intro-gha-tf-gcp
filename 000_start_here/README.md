# 000 — Start Here: Git & GitHub Setup

Do this once before starting the following exercises. If you've used
git for years, skim it for the vocabulary section — the mechanics
will be familiar. If you haven't, do every step by hand; typing the
commands is what makes them stick, and every later exercise in this
course assumes you can do this without looking it up.

## 1. Vocabulary, briefly

- **Repository ("repo")** — a project's full history, tracked by git.
  Lives both on your machine (a local clone) and on GitHub (the
  remote, called `origin` by convention).
- **Commit** — a saved snapshot of the files you've changed, with a
  message describing why. Commits are cheap and local until you
  `push` them.
- **Branch** — a named, independent line of commits. `main` is the
  default branch and (in this course) the one that represents "the
  real infrastructure." You never edit `main` directly — you branch
  off it, make changes, and merge back in.
- **Pull request (PR)** — a GitHub-specific concept, not a git one: a
  request to merge one branch into another, with a place for
  discussion, review, and (starting in
  [006_plan_on_pr_apply_on_merge](../006_plan_on_pr_apply_on_merge))
  automated checks, before the merge happens.
- **Clone vs. fork** — a clone is a full local copy of a repo you
  already have access to. A fork is a full *copy of the repo itself*
  under your own GitHub account, used when you don't have write access
  to the original. This course uses clones throughout — you'll always
  have collaborator access to whatever repo you're working in.

## 2. Set up git and GitHub

Two separate things need configuring once per machine: your local git
identity (stamped on every commit) and authentication to GitHub itself
(needed to clone, push, and open PRs).

**Git identity — this is one-time per machine.** If you've used git on
this computer before (even for something unrelated to this course),
you've likely already done this and can skip it. Check your entire
current config first:

```bash
git config --list
```

Look for `user.name` and `user.email` in the output. If both are
there, you're done — move on to GitHub auth below. If either is
missing:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Git stamps every commit with this name/email — it's how `git log` and
GitHub attribute work to you. If you skip this, git will refuse to
commit until you set it.

**GitHub authentication — use the GitHub CLI (`gh`).** It logs you in
through your browser and can wire itself up as git's credential
helper, so there's no SSH key to generate and no personal access
token to paste in later. It's the easiest correct path, especially if
you haven't done GitHub auth from the command line before.

Check whether it's already installed:

```bash
gh --version
```

If that fails, install it first:

- **macOS** (via [Homebrew](https://brew.sh)):
  ```bash
  brew install gh
  ```
  Don't have Homebrew? Install it first with the command on
  [brew.sh](https://brew.sh), or skip both and download the `gh`
  installer directly from [cli.github.com](https://cli.github.com).
- **Windows** (via `winget`, built into Windows 10/11 — run in
  PowerShell):
  ```powershell
  winget install --id GitHub.cli
  ```
  Alternatives: `choco install gh` (Chocolatey), `scoop install gh`
  (Scoop), or the installer from
  [cli.github.com](https://cli.github.com). Close and reopen your
  terminal after installing so it picks up the new command.

Then log in:

```bash
gh auth login
```

Answer the prompts: **GitHub.com** → **HTTPS** → **Yes** to
"Authenticate Git with your GitHub credentials?" → **Login with a web
browser**. It prints a one-time code and opens a browser tab —
approve it there. From then on, `git clone`/`push`/`pull` over HTTPS
just authenticate silently; nothing more to configure.

## 3. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/gitops-intro-gha-tf-gcp.git
cd gitops-intro-gha-tf-gcp
```

(If you're working from a fork, replace the URL with your fork's.)

## Next

[001_first_pull_request](../001_first_pull_request) puts all of this
to use — you'll branch, commit, push, open and merge a PR, work
through a merge conflict, and see what all of it has to do with
"GitOps."
