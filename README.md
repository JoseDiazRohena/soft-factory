# soft-factory

Prompts, slash commands, agents, skills and MCP configs for working with LLMs.

| Folder      | What goes there                                              |
|-------------|--------------------------------------------------------------|
| `prompts/`  | Standalone prompts and prompt snippets                       |
| `commands/` | Claude Code slash commands (`~/.claude/commands/*.md`)       |
| `agents/`   | Claude Code subagent definitions (`~/.claude/agents/*.md`)   |
| `skills/`   | Skills (one folder per skill, each with a `SKILL.md`)        |
| `mcp/`      | MCP server configs and notes                                 |

Keep secrets out of this repo: put API keys in `.env` files (ignored) or
reference environment variables in MCP configs.
