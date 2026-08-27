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
pipeline exercise after it, you'll copy that exercise's own workflow
file into this exact folder — `004_pipeline.yml`, then `005_pipeline.yml`,
then `006_pipeline.yml`. Each one is a new, uniquely-named file, not an
overwrite of the last, so nothing you build in an earlier exercise
gets erased — expect multiple checks to show up on a single PR once
you have more than one. That copy step is what actually makes a
workflow live. If this README is the only thing in here, you haven't
reached 004 yet.

[009_peer_review](../../009_peer_review) switches to a different
naming scheme once the course moves to a shared repo — one workflow
file per student (`YOUR_NAME-terraform.yml`), not one per exercise.
