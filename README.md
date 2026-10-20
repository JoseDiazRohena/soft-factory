# soft-factory

Prompts, slash commands, agents, skills and MCP configs for working with LLMs.

| Folder            | What goes there                                              |
|-------------------|--------------------------------------------------------------|
| `prompts/`        | Standalone prompts and prompt snippets (any harness)         |
| `mcp/`            | MCP server configs and notes                                 |
| `claude/commands/`| Claude Code slash commands (`~/.claude/commands/*.md`)       |
| `claude/agents/`  | Claude Code subagent definitions (`~/.claude/agents/*.md`)   |
| `claude/skills/`  | Skills (one folder per skill, each with a `SKILL.md`)        |

Everything under `claude/` is written for Claude Code. `next.md` and the agent
instructions also read `AGENTS.md`, so their text can be reused in other
harnesses, but the frontmatter is Claude-specific.

Keep secrets out of this repo: put API keys in `.env` files (ignored) or
reference environment variables in MCP configs.


## What exactly are we doing here?

### Orchestrator
This is a command meant to enable [loop engineering](https://ghuntley.com/loop/) workflows. The insight behind loop engineering is to keep the context window small by creating a new agent every time a change is approved and committed. The agent starts fresh and uses the contents of a TODO.md and a SPEC.md at the root of what you're building, along with the state of the code, to figure out what's going on.

One downside of this strategy is that it doesn't let us take advantage of the
magic of *caching*. To improve the cache performance, we don't throw out subagents after a task. Rather, we wait until their context reaches a certain size before refreshing them.

**Note:** Right now that threshold is purely *vibes*. Properly done, we would build some instrumentation and testing to find the best balance of 
cache performance and quality. But that's for later!

**How this one works:** Invoking the command when Claude Code is in your working repo turns your session into an orchestrator that creates worker and validator agents. Whenever a worker returns from a task, a validator checks the work and raises any issues for your review. It's not fully automated: you have the final say before committing.

## Install

Clone the repo and run the install script. It symlinks every command, agent
and skill into your Claude Code config folder, so a `git pull` updates them
in place.

```sh
git clone https://github.com/JoseDiazRohena/soft-factory.git
cd soft-factory
./install.sh
```

By default it installs into `$CLAUDE_CONFIG_DIR`, or `~/.claude` if that isn't
set. Pass a folder to install somewhere else, for example a single project:

```sh
./install.sh ~/code/my-project/.claude
```

- Files that already exist at the destination (and aren't symlinks) are left
  alone and reported as `skip`.
- Running it again is safe. It refreshes existing links and picks up new files.
- `prompts/` and `mcp/` aren't installed. Claude Code has no standard folder
  for them, so use them straight from the repo.

**Windows:** run the script from Git Bash (comes with
[Git for Windows](https://git-scm.com/download/win)) or WSL. Windows only
allows symlinks if **Developer Mode** is on (Settings → System → For
developers) or the terminal is running as Administrator. Without either, the
script stops with an error instead of quietly copying files.

From WSL, `~` is WSL's own home folder, not your Windows one. If you run
Claude Code on Windows itself, pass the Windows path:

```sh
./install.sh /mnt/c/Users/<you>/.claude
```

To uninstall, delete the symlinks from `~/.claude/commands`,
`~/.claude/agents` and `~/.claude/skills`.

## License

[MIT](LICENSE)
