---
name: permanent-memory-archive
description: Archive a permanent memory post in esa (bist team) to remove it from active permanent memory. Use when the user no longer needs to remember something, wants to retire an outdated memory, or clean up 永続 tagged posts. Trigger on: "永続記憶をアーカイブ", "この記憶いらない", "古いメモをアーカイブ", "archive permanent memory", "永続解除", "もう覚えなくていい", "記憶を消す", "永続メモを片付けて".
---

# permanent-memory-archive

esa `bist` チームの永続記憶ポストをアーカイブする。アーカイブ後はポストが `Archived/` カテゴリに移動し、永続記憶の検索対象から外れる。

## esa 接続

`mcp__esa__*` ツールを使用。認証トークンは MCP サーバーが Keychain `esa-mcp-token` から都度取得。

## アーカイブ手順

### 1. 対象ポストを特定

`esa_search_posts` を呼び出す:
- `teamName`: `"bist"`
- `query`: `"tag:永続 -in:Archived <キーワード>"`
- `sort`: `"updated"`, `order`: `"desc"`

キーワードが不明なら全件一覧表示してユーザーに選ばせる。
候補は番号・タイトル・更新日で列挙する。

### 2. 確認

ユーザーが「確認不要」「すぐやって」などを明示していない限り、対象ポストのタイトルと本文の冒頭を表示してアーカイブの意思を確認する。アーカイブは esa UI から手動で元に戻せるが、誤操作を防ぐための確認ステップ。

ユーザーが確認を明示的にスキップした場合はそのまま実行してよい。

### 3. アーカイブ実行

`esa_archive_post` を呼び出す:
- `teamName`: `"bist"`
- `postNumber`: 対象のポスト番号
- `message`: `"永続記憶から解除"`

### 4. 結果報告

アーカイブ後のポスト番号と移動先カテゴリ（`Archived/` 以下）をユーザーに伝える。

## 注意事項

- ポストは削除しない（`Archived/` カテゴリに移動するだけ）
- アーカイブ後も esa 上でポストは閲覧可能
- タグ `永続` はそのまま残るが、`-in:Archived` 検索で他のスキルから除外される
