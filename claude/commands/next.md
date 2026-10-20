---
description: Do the next unchecked TODO item, then stop for approval
argument-hint: [extra instructions]
---

Read CLAUDE.md, SPEC.md and TODO.md. If there's no CLAUDE.md, read
AGENTS.md instead; "CLAUDE.md" below means whichever one exists.

Do the next unchecked item in TODO.md (the first unchecked item in the first
step that has one). Do that one item only.

Notes:
- If what you build differs from SPEC.md, update SPEC.md to match.
- Add anything the next agent needs to know as sub-bullets under the item
  in TODO.md. Start each one with `NOTE:` so notes stand out from the task
  itself, e.g. `  - NOTE: config is loaded in src/config.ts`.
- Put open questions in your reply to me, not in files.

Before stopping, run the tests and checks listed in CLAUDE.md.

Don't commit yet. Stop and report: what you did, which checks passed, any
SPEC changes, and open questions. I'll approve or ask for changes.

When I approve, tick the item in TODO.md and commit everything for it in one
commit.

$ARGUMENTS
