---
name: permanent-memory-organize
description: Review and organize permanent memory posts in esa (bist team) tagged 永続. Use when the user explicitly wants to clean up, deduplicate, or consolidate their esa 永続 tagged posts. Trigger on: "永続記憶を整理", "記憶のクリーンアップ", "重複確認", "メモを見直して", "organize permanent memory", "永続タグのポストを整理", "記憶を棚卸し", "永続メモ棚卸し", "古い記憶を整理". Do NOT trigger for general database cleanup, "長期記憶DB", deleting DB entries, or any non-esa memory systems.
---

# permanent-memory-organize

esa `bist` チームの全永続記憶ポストをレビューし、重複・陳腐化・統合候補を見つけて整理する。

## esa 接続

`mcp__esa__*` ツールを使用。認証トークンは MCP サーバーが Keychain `esa-mcp-token` から都度取得。

## 整理手順

### 1. 全件取得

**検索対象は `tag:永続 -in:Archived` のみ。** esa チーム全体のポストを取得しない。

`esa_search_posts` を呼び出す:
- `teamName`: `"bist"`
- `query`: `"tag:永続 -in:Archived"`
- `sort`: `"updated"`, `order`: `"desc"`
- `perPage`: `100`

100件を超える場合はページングして全件取得する。`tag:永続` フィルタを外さないこと。

### 2. 分析

取得したポスト（タイトル・更新日・番号）を以下の観点で分析する:

| チェック観点 | 判断基準 |
|------------|---------|
| **重複** | タイトルや内容が類似している |
| **陳腐化** | 更新日が古い（目安: 6ヶ月以上未更新）かつ内容が時事的・バージョン依存 |
| **統合候補** | 関連する細切れのメモを1つにまとめられる |
| **タイトル改善** | タイトルが 180 文字超、またはキーワードブラケット形式でなく検索しにくい |

### 3. 提案を提示

分析結果をユーザーに提示する。承認なしに変更を実行しない。

提示例:
```
【重複候補】
- #123「[Ruby] バージョン管理」と #456「[rbenv] Ruby バージョン」→ 統合提案

【陳腐化候補】
- #789「[Claude] 旧モデルの設定」（最終更新: 2024-01-10）→ アーカイブ提案

【統合候補】
- #101「[家] Wi-Fi設定」と #102「[家] ルーター情報」→ 統合提案

【タイトル改善候補】
- #234「Rubyのインストールとかrbenvとかのメモ書き色々」→ 「[Ruby][rbenv] 環境構築メモ」へ変更提案
```

### 4. アクション実行

ユーザーが承認したアクションのみ実行する:

- **統合**: 対象ポストの本文を1つにまとめた上で `esa_update_post`、統合元を `esa_archive_post`
- **アーカイブ**: `esa_archive_post` を実行
- **タイトル修正**: `esa_update_post` でタイトルのみ更新（180文字以内、文字数カウント）
- **内容更新**: ユーザーと内容を確認してから `esa_update_post`

大量件数の場合は 10 件ずつ区切ってユーザーと確認しながら進める。

## 注意事項

- Archived ポストは分析対象外
- 統合時は元ポストの本文を失わないよう、マージ確認後にアーカイブ
- **承認なしに変更を実行しない**
