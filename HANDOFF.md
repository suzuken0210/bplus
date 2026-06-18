# bplus 開発 引き継ぎ書

> このドキュメントは、デスクトップのClaude（段取り・タスク整理担当）で進めた準備内容を、Claude Code（実装担当）に引き継ぐためのものです。
> 最終更新: 2026-06-18

---

## 1. プロダクト概要

**社内イベント電子チケット＆管理アプリ**

社内イベントの参加証を「電子チケット」として発行・管理し、社員の参加履歴を蓄積・可視化するアプリ。

- **解決する課題**: 社内イベントの「誰が何に参加したか」が組織として管理されていない。現状は集合写真依存で正確な実態把握が不可能。
- **ターゲットユーザー**: イベントを企画する幹事 / 参加する社員 / 組織コンディションを管理する人事担当者
- **主な機能（構想）**: イベント作成 / 電子チケット発行 / チケットアルバム（履歴）/ ユーザー認証 / 管理画面・参加データ出力
- **開発者視点のゴール**: 要件定義〜技術選定〜実装〜リリースまでの全工程を個人で完遂する。

詳細はNotion「📝 プロジェクト概要」参照。

---

## 2. 技術スタック

| レイヤー | 技術 | 状態 |
| --- | --- | --- |
| 参加者向けフロント | **React（Web / PWA）** | 未着手。※当面ネイティブアプリは作らない（下記決定事項） |
| Web管理画面 | React（Next.js or Vite は未決定） | 未着手 |
| モバイル（ネイティブ） | React Native（Expo）= 将来検討 | PWAで不足が出たら着手 |
| バックエンド | **Ruby on Rails（APIモード）** | 確定 |
| DB | PostgreSQL | 確定 |
| インフラ | AWS | 構成は要検討（下記） |

### AWS推奨構成（個人開発向け・最小セットから）
- バックエンド実行: **App Runner**（or ECS Fargate）
- DB: **RDS for PostgreSQL**
- 画像・ファイル: **S3**
- Web管理画面ホスティング: **Amplify Hosting**（or S3+CloudFront）
- 認証: Cognito を検討中（自前JWT/Deviseと比較してStep5で決定）
- その他候補: SES（メール）/ Secrets Manager / ECR / CloudWatch / CDK or Terraform

> ⚠️ コスト注意: RDS・App Runnerは起動しっぱなしで課金。開発初期は不要時に停止し、AWS Budgetsで月額アラート設定推奨。

---

## 3. リポジトリ現状

- リポジトリ: https://github.com/suzuken0210/bplus （main / origin設定済み）
- ローカル: `/Users/suzukikenta/katowork/bplus`
- 現在のファイル:
  - `README.md`（ほぼ空）
  - `.github/workflows/notion-sync.yml`（※ 後述の通り**現在は未使用方針**）
- Rails / React Native / React の雛形は**未作成**。Step1の環境構築はこれから。

---

## 4. タスク管理の方針（重要）

- **チケット管理はすべてNotionで行う**（GitHub Issueとの自動同期は断念）。
- GitHub Issue ⇄ Notion 自動同期を試みたが、Claude接続のGitHubコネクタが読み取り専用で書き込み403となり中断。`.github/workflows/notion-sync.yml` は残置しているが**動作させていない**。不要なら削除可。
- Issueを使いたい場合は、ローカルの `gh` CLI で一括作成するスクリプト案あり（Cowork出力フォルダの `create_issues.sh`）。ただし現方針はNotion一本化。
- 進捗管理はNotionの「📋 bplus タスク」DBとダッシュボードのカンバンで行う。

---

## 5. Notion 関連リンク

| ページ | URL |
| --- | --- |
| 個人開発（プロジェクトルート） | https://app.notion.com/p/375acb4d916680f5ae91c6867fcbab83 |
| 📝 プロジェクト概要 | https://app.notion.com/p/375acb4d9166802d857df2f8f2ba0442 |
| 🚀 bplus 開発ダッシュボード | https://app.notion.com/p/376acb4d916681ce9d61c0efd90cf5ee |
| 📋 bplus タスク（DB） | https://app.notion.com/p/abfb507718fd45c2a2214e11523fb62e |
| 🛠 開発ツール構成 | https://app.notion.com/p/37cacb4d9166818da652fecb705ceed4 |

### タスクDBのプロパティ
`タスク名 / ステータス / 種別 / 優先度 / 領域 / スプリント / Issue番号 / GitHub URL / Blocked / 完了日 / 作成日`

- ステータス: 📥 Backlog → 🎯 Sprint Todo → 🔨 In Progress（WIP最大2）→ 👀 Review → ✅ Done
- 種別: ✨ feature / 🐛 bug / 🔧 chore
- 領域: 📱 mobile / 💻 web / ⚙️ api / ☁️ infra

---

## 6. 開発ロードマップ（プレ開発フェーズ・全5 Step）

各タスクはNotionの「📋 bplus タスク」に登録済み。タスク名は `[StepN]` プレフィックス付き。

### Step 1: claude.md作成 ＆ 開発環境整備（= 現スプリント / Sprint 1）
1. claude.md作成：プロジェクト概要・目的・ターゲットを記載
2. claude.md作成：技術スタック・コーディング規約・ブランチ運用を記載
3. リポジトリ構成の決定（モノレポ/マルチレポ）とREADME更新
4. Rails API雛形作成（rails new --api + Docker構築）
5. PostgreSQL接続設定（docker-compose & DB作成確認）
6. 参加者向けWebフロント（PWA）の雛形作成（React + manifest/Service Worker・ホーム画面追加対応）
7. 管理画面（admin・Web）の雛形作成（Vite等選定込み）
8. リポジトリ初期化（.gitignore整備・ブランチ戦略反映・初回コミット/プッシュ）
9. 環境変数管理の整備（.env.example・Rails dotenv・各フロントのenv読み込み）
10. Lint/Formatter設定（RuboCop・ESLint・Prettier・.editorconfig）
11. 全環境のローカル起動確認＆セットアップ手順のREADME化（Rails/管理画面/参加者Webが起動する状態。← Step1の完了判定を兼ねる）

**推奨着手順**: claude.md（概要→技術/規約）→ リポジトリ構成決定 → リポジトリ初期化 → 各雛形（Rails→PostgreSQL→参加者Web(PWA)→管理画面）→ 環境変数 → Lint/Format → 全環境起動確認＆README化

### Step 2: 技術連携の初期検証（疎通確認）
- ヘルスチェックAPI実装（GET /api/v1/ping）/ CORS設定（rack-cors）/ RN→API疎通 / React管理画面→API疎通 / POST疎通（送信→DB保存→再取得）

### Step 3: 要件定義と機能の再検討（MVPとデータ要件の整理）
- 機能候補の洗い出しとMoSCoW分類（MVP確定）/ ユースケース記述 / 各機能のデータ項目テキスト化 / 画面一覧整理＋簡易ワイヤーフレーム

### Step 4: AWSハイレベル・インフラ構成図の作成
- AWS構成要素の選定（App Runner/ECS・RDS・S3・CloudFront等の比較）/ ハイレベル構成図作成（draw.io等）/ 概算コスト試算＆セルフレビュー

### Step 5: 詳細システム設計（DB設計/ER図・API設計）
- ER図作成（users/events/tickets ほか）/ テーブル定義書 / APIエンドポイント一覧定義 / リクエスト/レスポンス仕様（JSONスキーマ）/ 認証フロー設計（JWT発行〜更新・失効）

---

## 7. ツールの使い分け

| 用途 | ツール |
| --- | --- |
| エディタ | VS Code |
| AI（コード生成・実装） | Claude（エディタ連携 / Claude Code） |
| AI（タスク整理・段取り・設計相談） | Claude デスクトップ |
| コード管理 | GitHub |
| チケット・ドキュメント管理 | Notion |

---

## 8. 決定事項

- **参加者向けは Web（PWA）で提供する**（2026-06-18決定）。ネイティブアプリ（React Native）は当面作らず、Wallet連携・プッシュ到達率・本格オフラインなどPWAで不足が出た段階で追加検討する。Rails APIはWeb/ネイティブ両対応なので将来の追加に支障なし。
  - 理由: 社内アプリで配布が手軽（リンク共有のみ）/ チケットは"表示するだけ"でWebで十分 / モバイルのコードベースを1つ減らしMVPを最速化 / iOS16.4+でPWAプッシュも対応。
  - **再確認（2026-06-18）**: 参加者・管理画面ともに当面 **Web のみ** で進める方針を確定。
  - **構成決定（2026-06-18）**: 参加者画面は後々 **React Native（Expo）アプリとして切り出してリリースする可能性がある**ため、最初から **管理画面と参加者を別アプリ（2アプリ）** に分離する。
    - ディレクトリ: `apps/admin/`（管理画面）/ `apps/participant/`（参加者・PWA）。共有資産（API クライアント・TS 型・ドメインロジック）は `packages/` に置き、将来の RN からも再利用。
    - ビルドツールは **Vite に確定**（Next.js とは比較せず）。
    - 将来 RN 化時は `apps/mobile/`（Expo）を追加し `packages/*` を再利用、`apps/participant/`（PWA）は役割終了か併存。
    - これに伴い `CLAUDE.md` / `README.md` / `package.json`(workspaces=`apps/*`,`packages/*`) / `.env(.example)` を更新済み。

## 9. 未決事項 / 次のアクション

- [x] **Web（管理画面・参加者）は Next.js か Vite か** → **Vite に確定**（2026-06-18）
- [x] **参加者Webと管理画面を1リポジトリ/1アプリにまとめるか、分けるか** → **2アプリに分離**（`apps/admin` / `apps/participant`、2026-06-18）
- [x] **リポジトリ構成はモノレポかマルチレポか** → **モノレポ（Yarn workspaces）**（2026-06-18）
- [ ] **認証は Cognito か 自前JWT/Devise か**（Step5で決定）
- [ ] `.github/workflows/notion-sync.yml` を残すか削除するか

### Claude Codeでまず着手すると良いこと
1. このリポジトリに `claude.md`（or `CLAUDE.md`）を作成し、本書の内容（概要・技術スタック・規約・ディレクトリ構成方針）を反映
2. `.gitignore` 整備とリポジトリ構成の決定
3. Rails API雛形（`rails new --api`）+ Docker + PostgreSQL のローカル起動

> 進めたタスクはNotionの「📋 bplus タスク」で該当カードを In Progress / Done に動かして同期してください（手動運用）。
