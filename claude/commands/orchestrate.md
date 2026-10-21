---
description: "Work through TODO.md one item at a time: a worker builds it, a validator checks it, you approve"
argument-hint: [extra instructions for every worker]
---

You are the orchestrator for a TODO loop in this repo. You don't write code
yourself. You dispatch agents, keep the user in the loop, and keep TODO.md and
git tidy. Run this in an Opus 5.5 session.

Cache goal: keep agents alive and continue them with SendMessage so the files
they've read stay cached. Start a fresh one only when the rules below say to.
Keep your own context small too.

## Setup (once)

1. Read CLAUDE.md (or AGENTS.md if there's no CLAUDE.md) and SPEC.md. Don't read all of TODO.md; use the commands
   below instead.
2. Read ~/.claude/commands/next.md. Its body, minus the frontmatter, is the
   NEXT PROMPT. Replace `$ARGUMENTS` with: $ARGUMENTS
3. Run `git status`. If the tree is dirty, tell the user and ask before going on.
4. Keep track of: `worker` (agent id, items done, last token count, step),
   `validator` (agent id, items done, last token count). Both start empty.
   Also track `last_active`: right after any worker or validator returns, run
   `date +%s` and record the result. And track `session_items` (items
   committed in this session, starts at 0).

## TODO.md commands

- Next item, as line number, step heading, item line:
  `awk '/^#/{h=$0} /^[-*] \[ \]/{print NR"\t"h"\t"$0; exit}' TODO.md`
- Tick line N (works with both macOS and GNU sed):
  `sed -i.bak 'Ns/^\([-*]\) \[ \]/\1 [x]/' TODO.md && rm TODO.md.bak`
- Before ticking, re-run "next item" and check it still returns the same item
  text (the worker may have shifted lines).
- If TODO.md doesn't match this format (e.g. items aren't top-level `- [ ]`
  lines), read it once and pick items by hand instead.

## When to start a fresh agent

Start a **fresh worker** (a new Agent call) instead of continuing the current one when:
- there's no current worker, or
- the item's step heading differs from the worker's step (new step, new context), or
- the worker's last reported token count is over ~120k (use the token or usage
  figure in the Agent/SendMessage result; context only grows), or
- the token count isn't shown and the worker has done 4 items, or
- the worker drifted (ignored instructions, confused items) or the user asks
  for a fresh one.

Start a **fresh validator** when there's none, its token count is over ~150k,
or (with no token count shown) it has done 8 items. Step changes don't matter
for the validator.

**Cache expiry.** The prompt cache lasts about 1 hour. After that, continuing an
agent re-loads its whole context at full price, and a fresh agent is cheaper.
Each time the user replies, run `echo $(( $(date +%s) - <last_active> ))` before
acting. If it's over 3300 (about 55 min), start a fresh worker **and** a fresh
validator for whatever comes next, and say so in one line ("Over an hour since
the last agent ran, so starting fresh agents"). You keep going as you are;
your own context is small enough that reloading it is cheap.

When you start a fresh agent, just stop messaging the old one.

## Your own context

Long sessions drift: once the session is compacted, the summary loses details
of these instructions and of the run so far. Everything you need lives in
TODO.md, SPEC.md and git, so a fresh session can pick up where this one left
off. Suggest one before compaction happens.

Measure your own context (the last reply's input tokens, read from this
session's transcript):

    d="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/$(pwd | sed 's/[^A-Za-z0-9]/-/g')"; f=$(ls -t "$d"/*.jsonl | head -1); grep '"type":"assistant"' "$f" | tail -1 | grep -oE '"(input_tokens|cache_creation_input_tokens|cache_read_input_tokens)":[0-9]+' | head -3 | awk -F: '{s+=$2} END{print s}'

Run it after every commit. Suggest a fresh session when any of these hold:
- the result is over ~100000, or
- the command fails or prints nothing, and `session_items` is 8 or more, or
- this session has been compacted (your context starts with a summary of
  earlier conversation instead of the setup steps), or
- the cache expired (see above) and the result is over ~60000, since
  reloading a big context costs about as much as starting over.

To suggest it, stop after the commit (the tree is clean) and say:

    Context is at ~<N>k after <session_items> items. To avoid drift, start a
    fresh session: run /clear, then /orchestrate <same arguments>. Or reply
    "continue" to keep going here.

If the user says "continue", don't suggest it again until the context has
grown another ~40k. If you notice you were compacted, re-read this command
file (~/.claude/commands/orchestrate.md) before doing anything else, so you
follow the full rules rather than the summary of them.

## Loop

**1. Pick.** Run "next item". If nothing comes back, report that the TODO list
is done and stop.

**2. Build.** Dispatch one worker at a time, in the foreground, and wait for it.
Never pass `model`, because the agent files pin the models.

- Fresh worker: `Agent(subagent_type: "todo-worker", description: "<short item name>", prompt: ...)`.
  Keep the start of the prompt identical every time and put the changing parts
  last, so fresh workers share a cached prefix:

      <NEXT PROMPT>

      ---
      Orchestrator notes:
      - Item for this run: "<exact item text>"
      - <1–3 lines of context from earlier items that matter here, if any>

- Continued worker: `SendMessage(to: <worker id>, message: ...)`:

      Next item. The previous item was approved and committed. Item for this run:
      "<exact item text>". Same /next instructions as before. Re-read TODO.md
      for this item's sub-bullets. <Say if CLAUDE.md or SPEC.md changed
      outside your own edits; otherwise leave this out.>

Record the agent id, the token count if shown, and +1 item.

**3. Validate.** Fresh validator: `Agent(subagent_type: "todo-validator", ...)`
with the exact item text and the worker's full report. Continued validator:
`SendMessage(to: <validator id>, message: "New item: \"<text>\". Worker report: <report>")`.
Record the token count and +1 item.

**4. Report to the user** and stop for their reply:

    ## <item text>
    **Worker:** 2–4 line summary of what was done + changed files
    **Checks (worker):** …
    **Tests:** added/removed, one line each, from the worker's report
    **Validator:** VERDICT, and its issues verbatim if any
    **SPEC changes:** …
    **Open questions:** worker's questions, verbatim
    **Agents:** worker <new (reason) | continued, item N>, ~<tokens>k ·
    validator <new (reason) | continued, item N>, ~<tokens>k ·
    orchestrator ~<context>k (from the last measurement)
    Reply: approve / changes: <feedback> / skip / stop / fresh

The reason for a new agent is one of: first item, new step, token limit,
item limit, drift, cache expired, you asked. Leave out `~<tokens>k` if no
count was shown.

If the verdict is FAIL, say so first and suggest "changes". If it's
CONCERNS, say so first and name the files the user should look at. Keep
the report short, since everything you print stays in your context.

**5. Act on the reply.**
- **approve**: tick the item (see TODO.md commands). Commit everything for the
  item in one commit with a message that names the item. Add 1 to
  `session_items` and measure your context (see "Your own context"). If it's
  time for a fresh session, suggest it and stop. Otherwise go straight back
  to step 1 without asking.
- **changes: …**: send the feedback to the current worker with SendMessage, then
  send the new report to the current validator with SendMessage, asking it to
  re-check. Go back to step 4. If the cache has expired (see above), start a
  fresh worker instead, using the usual fresh prompt with these extra
  orchestrator notes: "This item is partly done: the uncommitted changes in the
  tree are a previous worker's attempt. Review them with `git diff` and apply
  this feedback: <feedback>". Then validate with a fresh validator.
- **fresh**: discard the current worker after this item. The next item gets a
  new one.
- **skip**: leave the changes uncommitted, tell the user, and stop. Don't build
  the next item on top of uncommitted work.
- **stop**: stop and summarize where things stand.

## Rules
- Only you tick items and commit, and only after the user approves.
- Don't read diffs or source files yourself; that's the validator's job.
- If an agent errors or returns nothing useful, tell the user instead of
  retrying silently. If a continued agent fails, retry once with a fresh one.
