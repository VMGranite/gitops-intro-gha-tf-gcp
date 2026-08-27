# Workflows land here

This directory starts empty on purpose (this file doesn't count —
GitHub Actions only reads `.yml`/`.yaml` files, so it's ignored). It's
committed just so the path exists and is easy to find.

GitHub Actions only ever discovers workflows at this exact path,
`.github/workflows/`, at the **repo root** — never inside any
exercise's own folder, no matter how many exercises have their own
copy sitting in `NNN_exercise/task/.github/workflows/`.

Starting at
[004_basic_pipeline](../../004_basic_pipeline/task), and in every
pipeline exercise after it, you'll copy that exercise's own
`.github/workflows/terraform.yml` into this exact folder — overwriting
whatever the previous exercise left here. That copy step is what
actually makes a workflow live. If this README is the only thing in
here, you haven't reached 004 yet.
