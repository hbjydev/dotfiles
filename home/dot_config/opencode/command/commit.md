---
description: Create conventional commits from all changes
agent: general
---

Analyse ALL current git changes (staged AND unstaged) and create one or more commits following the Conventional Commits specification EXACTLY.

CRITICAL REQUIREMENTS:
1. Every commit message MUST follow this EXACT format:
   ```
   <type>(<scope>): <description>

   [optional body]

   [optional footer(s)]
   ```

2. Valid types (MUST use one of these):
   - feat: new feature
   - fix: bug fix
   - docs: documentation only changes
   - style: formatting, missing semi colons, etc (not CSS)
   - refactor: code change that neither fixes a bug nor adds a feature
   - perf: performance improvement
   - test: adding or correcting tests
   - build: changes to build system or dependencies
   - ci: changes to CI configuration
   - chore: other changes that don't modify src or test files

3. Rules for scope:
   - MUST be lowercase
   - Use specific component/module names (e.g., "auth", "api", "frontend", "parser")
   - Can be omitted if change affects multiple areas

4. Rules for description:
   - MUST be lowercase
   - MUST NOT end with a period
   - MUST be imperative mood ("add" not "added" or "adds")
   - MUST be concise (max 72 chars for first line)

5. Breaking changes:
   - MUST be indicated by "!" after type/scope: `feat(api)!: remove deprecated endpoint`
   - MUST include "BREAKING CHANGE:" in footer

WORKFLOW:
1. Run `git status` and `git diff` to see all changes
2. Group related changes logically
3. For each group, determine:
   - The correct type
   - The appropriate scope
   - A clear, imperative description
4. Stage and commit each group separately

EXAMPLES OF CORRECT MESSAGES:
```
feat(auth): add oauth2 support

Implemented Google and GitHub OAuth providers with token refresh.

Closes #123
```

```
fix(parser): handle null values correctly

Previously would throw when encountering null in nested objects.
```

```
docs(readme): update installation instructions
```

```
refactor(api)!: remove legacy endpoints

BREAKING CHANGE: /api/v1/* endpoints removed, use /api/v2/* instead
```

First, show me what changes exist and propose how you'll group them into commits. Then create the commits.

DO NOT create commits that don't follow this exact format. If you're unsure, ask me first.
