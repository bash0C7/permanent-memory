# permanent-memory

Ruby MCP server that provides esa-backed permanent memory for Claude Desktop and Claude Code.

## What it does

Exposes three MCP tools backed by esa.io so Claude can search, create, and update persistent memory posts:

| Tool | Description |
|---|---|
| `permanent_memory_search` | Search posts tagged `永続` (excluding Archived) |
| `permanent_memory_create` | Create a new permanent memory post |
| `permanent_memory_update` | Update an existing post (with conflict detection) |

Claude Code users also get three skills:

- `/permanent-memory-setup` — Initial setup (dependencies, Keychain token, Claude Desktop config)
- `/permanent-memory-archive` — Archive a post (remove from active memory)
- `/permanent-memory-organize` — Review and clean up all permanent memory posts

**Backend**: esa.io `bist` team, posts tagged `永続`

## Setup

Open this repository in Claude Code and run:

```
/permanent-memory-setup
```

The skill guides you through dependency installation, esa API token registration in macOS Keychain, and Claude Desktop configuration.

> **Authentication note:** `scripts/start_mcp.sh` reads `esa-mcp-token` from the macOS Keychain at startup. No secrets are stored in code or config files.

## Project structure

```
scripts/
  mcp_server.rb   # MCP tool definitions (search / create / update)
  start_mcp.sh    # Keychain auth + server launcher
Gemfile           # Dependencies: mcp gem, test-unit
```
