---
name: git-auto-commit
description: Create intermediate git commits after code changes. Use when asked to commit work-in-progress, leave a clean history, summarize changes into a commit message, or apply a commit template. Ensure git status is checked before committing and stage all changes with git add -A.
---

# Git Auto Commit

## Workflow

1. Confirm repo state and identify a meaningful change bundle.
   - Run `git status -sb` and scan for files related to the same change intent.
   - If the bundle is unclear, ask a brief clarification before committing.
2. Stage all changes for the bundle.
   - Run `git add -A`.
   - Re-check `git status -sb` to confirm staging.
3. Summarize changes for the commit message.
   - Use `git diff --cached --stat` (and `git diff --cached` if needed) to capture the main changes.
4. Build the commit message using the template guidance.
   - Reference `commit_template.txt` for the required structure and allowed types.
   - Title: one concise summary sentence of the bundle.
   - Body: bullet list of the key changes.
   - If the repo has additional rules (ticket tags, scopes, Conventional Commits), comply.
5. Commit.
   - Prefer a **single** body paragraph so Git doesn't insert blank lines between items.
   - Use `git commit -m "<title>" -m $'- item 1\n- item 2'` (single `-m` for the body) to keep bullets contiguous.
   - Do not include commented template lines in the final message.

## Guardrails

- Do not commit if there are no changes (`git status -sb` clean).
- Keep commits scoped to one meaningful change bundle.
- If unsure about grouping or message format, ask a single clarifying question.
