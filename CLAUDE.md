# permanent-memory

Ruby MCP server providing esa-backed permanent memory for Claude Desktop and Claude Code.

## Overview

- **MCP tools** (all clients): `permanent_memory_search`, `permanent_memory_create`, `permanent_memory_update`
- **Skills** (Claude Code only): `permanent-memory-archive`, `permanent-memory-organize`
- **Backend**: esa.io `bist` team, posts tagged `永続`

## Setup

```sh
bundle install
```

## Claude Desktop config

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
"permanent-memory": {
  "command": "/Users/bash/dev/src/github.com/bash0C7/permanent-memory/scripts/start_mcp.sh"
}
```

## Authentication

`start_mcp.sh` reads `esa-mcp-token` from macOS Keychain at startup and passes it as `ESA_ACCESS_TOKEN` environment variable. No secrets are stored in code or config files.

## Skills

Run from Claude Code inside this repository directory:

- `/permanent-memory-archive` — Archive a post (remove from active memory)
- `/permanent-memory-organize` — Review and clean up all permanent memory posts
