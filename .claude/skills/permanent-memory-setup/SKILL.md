---
name: permanent-memory-setup
description: Use when setting up the permanent-memory MCP server for the first time, or when a user needs to install dependencies, register the esa API token in Keychain, or configure Claude Desktop. Triggers on: "セットアップ", "setup", "install", "初期設定", "動かしたい", "トークン登録", "Claude Desktop に追加".
---

# permanent-memory-setup

permanent-memory MCP サーバーの初期セットアップを案内する。

## 手順

### 1. 依存インストール

```sh
cd /path/to/permanent-memory
bundle install
```

### 2. esa API トークンを Keychain に登録

```sh
security add-generic-password -s 'esa-mcp-token' -a "$USER" -w '<your-esa-token>'
```

- トークンは esa.io の設定画面（Personal access tokens）で発行
- 登録済み確認: `security find-generic-password -s 'esa-mcp-token' -w`

### 3. Claude Desktop に MCP サーバーを追加

`~/Library/Application Support/Claude/claude_desktop_config.json` を編集:

```json
{
  "mcpServers": {
    "permanent-memory": {
      "command": "/path/to/permanent-memory/scripts/start_mcp.sh"
    }
  }
}
```

Claude Desktop を再起動して反映。

### 4. 動作確認

Claude Desktop / Claude Code で以下を試す:

- 「永続記憶を検索して」→ `permanent_memory_search` が動けばOK
- エラーが出る場合は `start_mcp.sh` を直接実行してログを確認:
  ```sh
  bash /path/to/permanent-memory/scripts/start_mcp.sh
  ```

## トラブルシュート

| 症状 | 原因 | 対処 |
|---|---|---|
| `esa-mcp-token not found` | Keychain 未登録 | 手順2を実施 |
| `bundle: command not found` | rbenv/bundler 未設定 | `gem install bundler` |
| ツールが Claude に表示されない | claude_desktop_config.json の構文エラーまたは再起動未実施 | JSON を確認・再起動 |
