.DEFAULT_GOAL := help

.PHONY: help up down build api-setup api-console api-bash api-migrate logs ps

help: ## このヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

up: ## Docker（api + db）をバックグラウンド起動
	docker compose up -d

down: ## Docker を停止
	docker compose down

build: ## イメージを再ビルド
	docker compose build

api-setup: ## DB 作成・マイグレーション（初回セットアップ）
	docker compose run --rm api bundle exec rails db:create db:migrate

api-migrate: ## マイグレーション実行
	docker compose run --rm api bundle exec rails db:migrate

api-console: ## Rails コンソールを起動
	docker compose run --rm api bundle exec rails console

api-bash: ## api コンテナにシェルで入る
	docker compose run --rm api bash

logs: ## ログを表示（追従）
	docker compose logs -f

ps: ## 起動中のコンテナを表示
	docker compose ps
