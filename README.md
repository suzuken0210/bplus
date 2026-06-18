# bplus

社内イベント電子チケット＆管理アプリ。社内イベントの参加証を「電子チケット」として発行・管理し、社員の参加履歴を蓄積・可視化する。

## 構成（モノレポ）

| ディレクトリ | 内容 | 技術 |
| --- | --- | --- |
| `api/` | バックエンド API | Ruby on Rails 8（APIモード）+ PostgreSQL |
| `apps/admin/` | 管理画面 | React + Vite |
| `apps/participant/` | 参加者フロント（PWA） | React + Vite |
| `packages/` | 共有コード（API クライアント・型など） | TypeScript |

> 当面は参加者・管理画面ともに **Web のみ**。ただし参加者画面は後々 React Native（Expo）アプリとして切り出す可能性があるため、**管理画面と参加者を別アプリ（2アプリ）** に分離する構成（方針: 2026-06-18）。

開発ルール・規約は [CLAUDE.md](CLAUDE.md) を参照。

## 必要なもの

- Docker Desktop（api + db の起動に使用）
- Node.js 20 以上 / Yarn（フロント `apps/*` 用）

## セットアップ

```bash
# 1. 環境変数を用意
cp .env.example .env

# 2. バックエンド（Rails + PostgreSQL）を起動
make build        # 初回のみ：イメージをビルド
make api-setup    # DB 作成・マイグレーション
make up           # 起動（http://localhost:3000）

# 動作確認
curl http://localhost:3000/up        # Rails ヘルスチェック → 200

# 停止
make down
```

主要な make コマンドは `make help` で一覧表示できる。

### フロント（管理画面 / 参加者）

管理画面 `apps/admin` と参加者 `apps/participant` を Vite で起動する。共有コード（API クライアント・型）は `packages/` に配置。Node はリポジトリ直下の `.node-version`（24.16.0）に従う（nodenv 等で自動切替）。

```bash
# 1. 依存をインストール（ルートで Yarn workspaces をまとめて解決）
yarn install

# 2. フロントを起動（別ターミナルで）
yarn dev:admin          # 管理画面 → http://localhost:5173
yarn dev:participant    # 参加者     → http://localhost:5174

# まとめてビルド / 型チェック
yarn build
yarn typecheck
```

参加者アプリは PWA 対応（`public/manifest.webmanifest` + `public/sw.js`）。Service Worker は本番ビルドでのみ登録される。API のベース URL は `.env` の `VITE_API_BASE_URL` を参照する。
