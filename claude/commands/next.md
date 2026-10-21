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

Tests (CLAUDE.md wins if it sets its own rules):
- Write the fewest tests that would catch this item breaking. Usually 1–3.
  Zero is fine for refactors, config, copy or glue that existing tests
  already cover.
- Test only what this item adds or changes, through the way it's actually
  called (the public function, endpoint or command). Not private helpers, not
  other items' code, not libraries or the framework.
- One test per behaviour, not per input. If a few inputs matter, use one
  table-driven or parametrized test.
- Input validation: test it once, where outside input enters (request
  handler, CLI parser, file loader): one rejected input, plus one accepted
  edge case if it isn't obvious. Don't re-test validation in code that only
  ever gets already-checked data, and don't list every malformed string.
- Skip tests for things the type checker or linter catches, trivial
  getters and constructors, "the mock was called", and anything an existing
  test already covers. Extend an existing test before adding a new one.
- If you change behaviour, update or delete the tests for the old
  behaviour. Don't leave dead tests behind.

Before stopping, run the tests and checks listed in CLAUDE.md.

Don't commit yet. Stop and report: what you did, which checks passed, tests
added or removed (one line each on what it covers), any SPEC changes, and
open questions. I'll approve or ask for changes.

When I approve, tick the item in TODO.md and commit everything for it in one
commit.

$ARGUMENTS
