# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # 生成先は api/openapi.yaml（リポジトリの契約の正）。
  config.openapi_root = Rails.root.to_s

  # request spec の path/response 記述からこの定義へマージして openapi.yaml を生成する。
  config.openapi_specs = {
    "openapi.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "bplus API",
        version: "0.1.0",
        description: "社内イベント電子チケットアプリの API 仕様（request spec から自動生成）。"
      },
      servers: [
        { url: "/" }
      ],
      components: {
        schemas: {
          Event: {
            type: :object,
            additionalProperties: false,
            required: %w[id event_name created_at updated_at discarded_at],
            properties: {
              id: { type: :string, description: "UUID" },
              event_name: { type: :string },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              discarded_at: { type: :string, format: "date-time", nullable: true, description: "論理削除日時。未削除なら null。" }
            }
          },
          CreateEventRequest: {
            type: :object,
            additionalProperties: false,
            required: %w[event],
            properties: {
              event: {
                type: :object,
                additionalProperties: false,
                required: %w[event_name],
                properties: {
                  event_name: { type: :string }
                }
              }
            }
          },
          ValidationError: {
            type: :object,
            additionalProperties: false,
            required: %w[errors],
            properties: {
              errors: { type: :array, items: { type: :string } }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
