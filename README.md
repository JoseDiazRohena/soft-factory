# soft-factory

Prompts, slash commands, agents, skills and MCP configs for working with LLMs.

| Folder      | What goes there                                              |
|-------------|--------------------------------------------------------------|
| `prompts/`  | Standalone prompts and prompt snippets                       |
| `commands/` | Claude Code slash commands (`~/.claude/commands/*.md`)       |
| `agents/`   | Claude Code subagent definitions (`~/.claude/agents/*.md`)   |
| `skills/`   | Skills (one folder per skill, each with a `SKILL.md`)        |
| `mcp/`      | MCP server configs and notes                                 |

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

Keep secrets out of this repo: put API keys in `.env` files (ignored) or
reference environment variables in MCP configs.
