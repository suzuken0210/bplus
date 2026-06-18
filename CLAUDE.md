# CLAUDE.md — bplus

社内イベント電子チケット＆管理アプリ。Claude Code（実装担当）向けのプロジェクト規約。

## 1. プロダクト概要

社内イベントの参加証を「電子チケット」として発行・管理し、社員の参加履歴を蓄積・可視化するアプリ。

- **課題**: 社内イベントの「誰が何に参加したか」が組織として管理できていない（集合写真依存で実態把握が困難）。
- **ユーザー**: イベントを企画する幹事 / 参加する社員 / 組織コンディションを管理する人事担当者。
- **主な機能（構想）**: イベント作成 / 電子チケット発行 / チケットアルバム（履歴）/ ユーザー認証 / 管理画面・参加データ出力。

## 2. 技術スタック

| レイヤー | 技術 | ディレクトリ |
| --- | --- | --- |
| 管理画面（admin） | React（**Vite**） | `apps/admin/` |
| 参加者フロント | React（**Vite**）+ PWA | `apps/participant/` |
| バックエンド | **Ruby on Rails 8（APIモード）** | `api/` |
| DB | PostgreSQL | （Docker `db`） |
| 共有コード | TypeScript（API クライアント・型・ドメインロジック） | `packages/` |
| インフラ | AWS（App Runner / RDS / S3 / Amplify。Step4で確定） | `deploy/`（将来） |

ローカル開発は Docker Compose（`api` + `db`）で行う。フロントは `apps/admin` / `apps/participant` を各々で起動。

> **方針（2026-06-18）**: 参加者・管理画面ともに当面 **Web のみ** で提供する。ただし**参加者画面は後々 React Native（Expo）アプリとして切り出してリリースする可能性がある**ため、最初から **管理画面と参加者を別アプリ（2アプリ）** に分離する。共有資産（API クライアント・TS 型・ドメインロジック）は `packages/` に置き、将来の RN アプリからも再利用する。
> 将来 RN 化する際は `apps/mobile/`（Expo）を追加して `packages/*` を再利用し、`apps/participant/`（PWA）は役割を終えるか併存させる。

## 3. リポジトリ構成（モノレポ）

```
bplus/
├── CLAUDE.md / README.md / Makefile
├── docker-compose.yml          # api + db（最小構成）
├── docker/dev/api/Dockerfile   # Rails 開発用イメージ
├── .env.example                # 環境変数テンプレート
├── package.json                # Yarn workspaces ルート（apps/* / packages/*）
├── api/                        # Rails 8 API（共通バックエンド）
├── apps/
│   ├── admin/                  # 管理画面（Vite + React）
│   └── participant/            # 参加者（Vite + React + PWA）← 後々 apps/mobile (Expo) へ載せ替え
└── packages/                   # 共有 TypeScript（api-client / types など。RN からも再利用）
```

## 4. コーディング規約

- **コミュニケーション・コメントは日本語**（技術用語・コード・識別子は英語）。
- **Lint/Format に従う**: Rails=RuboCop / TS=ESLint + Prettier。コミット前に整形する。
- 不明点は推測で進めず、確認する。
- API のエンドポイントは `/api/v1/` 配下にバージョニングする。

## 5. ブランチ運用（GitHub Flow）

- `main` は常にデプロイ可能な状態を保つ。直接コミットしない。
- 作業はブランチを切る: `feature/<概要>` / `fix/<概要>` / `chore/<概要>`。
- PR を作成してマージ。コミットメッセージ・PR は日本語で簡潔に。

## 6. 開発コマンド（Makefile）

| コマンド | 内容 |
| --- | --- |
| `make up` | Docker（api + db）を起動 |
| `make down` | 停止 |
| `make api-setup` | DB 作成・マイグレーション |
| `make api-console` | Rails コンソール |
| `make api-bash` | api コンテナにシェルで入る |
| `make logs` | ログ表示 |

## 7. タスク管理

進捗は Notion「📋 bplus タスク」DB で管理（手動運用）。着手時に In Progress、完了時に Done へ移動する。
ステータス: 📥 Backlog → 🎯 Sprint Todo → 🔨 In Progress（WIP最大2）→ 👀 Review → ✅ Done。
