---
name: address-pr-comments
description: >
  Address GitHub PR review comments by reading feedback, making code changes, and replying to reviewers.
  Use this skill when the user wants to address PR comments, fix review feedback, respond to PR reviews,
  handle code review suggestions, or says things like "address the PR feedback", "fix the review comments",
  "handle the PR comments on #123". Also trigger for slash command /address-pr-comments. This skill should
  be used proactively whenever the user mentions PR reviews, review comments, or code review feedback that
  needs to be acted on — even if they don't explicitly say "address".
---

# Address PR Comments

Read PR review comments, evaluate each one critically, make code changes, and
reply to reviewers — all in a structured workflow that prevents blind agreement
and ensures technical correctness.

## Philosophy

This skill builds on the **receiving-code-review** principle: review feedback is
input to evaluate, not orders to follow. Every comment gets verified against the
codebase before implementation. Pushback is expected when feedback is
technically incorrect or conflicts with architectural decisions.

## Workflow

### Step 1: Identify the PR

Determine the PR from context:
- User provides a URL: `https://github.com/org/repo/pull/123`
- User provides a number: `#123` or `PR 123`
- Infer from current branch: `gh pr view --json number,url`

If ambiguous, ask.

### Step 2: Fetch All Review Comments

Use the GitHub CLI to get the full picture before acting on anything:

```bash
# Get PR metadata
gh pr view {number} --json title,body,baseRefName,headRefName,reviewDecision,reviews

# Get all review comments (inline + review-level)
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate

# Get issue-level comments (top-level PR conversation)
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Read all comments before reacting to any of them. Comments may be related —
understanding the full set prevents partial or contradictory fixes.

### Step 3: Categorise Each Comment

For every comment, classify it:

| Category | Criteria | Action |
|----------|----------|--------|
| **Actionable** | Clear request, technically sound, applies to this codebase | Address it |
| **Unclear** | Ambiguous intent, could mean multiple things | Ask the user for clarification |
| **Disagree** | Technically incorrect, breaks things, conflicts with architecture, or YAGNI | Flag for user with reasoning |
| **Already resolved** | Outdated by subsequent commits or other comment resolutions | Note as resolved |
| **Nitpick/style** | Subjective preference with no functional impact | Flag for user — they decide |

To categorise correctly, you must actually check the codebase:
- Read the file(s) the comment references
- Understand why the code is written the way it is
- Check if the suggestion would break anything
- Look for context the reviewer might be missing

### Step 4: Present the Plan

Before making any changes, show the user a summary:

```
## PR #123 Review Comments — 7 comments from @reviewer

### Will address (4):
1. `modules/foo/main.tf:42` — Add validation block for `zone` variable
2. `modules/foo/main.tf:87` — Fix typo in description: "instace" → "instance"
3. `modules/foo/variables.tf:15` — Add `nullable = true` to optional variable
4. `modules/foo/outputs.tf:8` — Add example to output description

### Need your input (2):
5. `modules/foo/main.tf:30` — Reviewer suggests using `for_each` instead of `count`.
   Current code uses `count` because [reason]. The `for_each` approach would [trade-off].
   → What do you prefer?
6. `modules/foo/lookups.tf:12` — Reviewer says "this local seems unnecessary".
   It's used by [X, Y, Z]. Removing it would require inlining in 3 places.
   → Keep or refactor?

### Already resolved (1):
7. `modules/foo/main.tf:55` — Was about a missing output; added in commit abc123.
```

Wait for the user to confirm or adjust before proceeding.

### Step 5: Make Changes

Address comments in this order:
1. **Blocking issues** — anything that breaks correctness or security
2. **Simple fixes** — typos, missing descriptions, formatting
3. **Complex changes** — refactoring, logic changes, new resources

For each change:
- Read the relevant file(s) first
- Make the change
- Verify it doesn't break anything (`terraform validate`, `cargo check`, or
  whatever applies)

### Step 6: Decide Commit Strategy

Assess based on the changes made:

- **Few small, related changes** → single commit covering all review feedback
- **Mix of unrelated changes** → group into logical commits (e.g., one for
  typos, one for validation, one for refactoring)
- **Large or complex change from a single comment** → its own commit

Use the project's commit message convention. For review feedback, a pattern like:

```
fix(module_name): [TICKET-ID] address PR review feedback

- Add validation block for zone variable
- Fix typo in output description
- Add nullable annotation to optional variable
```

If you're unsure about the right granularity, ask the user.

### Step 7: Reply to Comments on GitHub

After changes are committed, reply to each comment thread on GitHub. Replies go
in the **existing thread** (not as top-level comments):

```bash
# Reply to an inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -f body="Fixed — added validation block with descriptive error message. See [commit]."

# Reply to a top-level issue comment
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="Addressed in [commit hash]:\n- Item 1: done\n- Item 2: done\n- Item 3: see below"
```

Reply content should be:
- **Concise** — state what was done, not why the reviewer was right
- **Reference the fix** — mention the commit or link to the changed lines
- **No performative agreement** — no "great catch!", no "you're absolutely
  right!", no "thanks for the feedback!"
- **Technical when pushing back** — if you disagreed and the user confirmed,
  explain the reasoning factually

Good replies:
- "Fixed in abc123 — added validation block."
- "Resolved — the typo was in the description, not the variable name. Corrected
  both."
- "Keeping the current approach — this uses `count` because the instances are
  ordered and index-sensitive. `for_each` would break the zone-to-index mapping
  used downstream."

Bad replies:
- "Great catch! Fixed!"
- "You're absolutely right, I should have done this from the start."
- "Thanks for pointing this out!"

### Step 8: Push and Report

Push the changes and give the user a summary:

```
## Done — PR #123 comments addressed

### Changes made:
- abc123: fix(foo): address review feedback (3 comments)
- def456: refactor(foo): convert to for_each per review (1 comment)

### Replies posted:
- 4 comments replied to on GitHub
- 2 flagged items resolved per your direction
- 1 already-resolved comment noted

### Remaining:
- None (all addressed)
```

## Handling Edge Cases

**Comment references deleted/moved code**: Check git history to understand where
the code went. If it was intentionally removed, reply explaining that.

**Reviewer and user disagree**: The user's decision is final. Reply to the
reviewer with the user's reasoning, framed technically.

**Comment is on a file you can't find**: The PR might span multiple repos or the
file path changed. Ask the user rather than guessing.

**Reviewer requests a large refactor**: Flag it. This may warrant its own
branch/PR rather than being squeezed into review feedback.

**Stale comments from previous review rounds**: Check if the comment's
`position` still maps to current code. If the code has changed significantly,
note it as potentially stale and verify with the user.

## What This Skill Does NOT Do

- **Create PRs** — use other workflows for that
- **Approve or request changes** — that's the reviewer's job
- **Merge** — always the user's decision
- **Auto-resolve without showing you** — every change is presented first
