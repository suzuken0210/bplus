require "swagger_helper"

# このファイルは「events API の OpenAPI 契約（スキーマ）の検証」と「openapi.yaml の生成元」を兼ねる。
# rake rswag:specs:swaggerize で api/openapi.yaml が生成される。
# 詳細な振る舞いテストは spec/requests/api/v1/events_controller/ 配下が担う。
# レスポンス形状を変更する際は両方を併せて更新すること。
RSpec.describe "Events API", type: :request do
  path "/api/v1/events" do
    get "イベント一覧（有効なもののみ・作成順）" do
      tags "Events"
      produces "application/json"

      response 200, "イベントの配列" do
        schema type: :array, items: { "$ref" => "#/components/schemas/Event" }

        before { Event.create!(event_name: "サンプルイベント") }

        run_test!
      end
    end

    post "イベントを1件作成" do
      tags "Events"
      consumes "application/json"
      produces "application/json"
      parameter name: :event, in: :body, schema: { "$ref" => "#/components/schemas/CreateEventRequest" }

      response 201, "作成されたイベント" do
        schema "$ref" => "#/components/schemas/Event"
        let!(:event) { { event: { event_name: "歓迎会", held_at: "2026-08-01T19:00:00Z" } } }
        run_test!
      end

      response 422, "バリデーションエラー" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let!(:event) { { event: { event_name: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/events/{id}" do
    patch "イベントを1件更新" do
      tags "Events"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string, description: "イベントID（UUID）"
      parameter name: :event, in: :body, schema: { "$ref" => "#/components/schemas/UpdateEventRequest" }

      response 200, "更新されたイベント" do
        schema "$ref" => "#/components/schemas/Event"
        let!(:id) { Event.create!(event_name: "歓迎会").id }
        let!(:event) { { event: { event_name: "歓迎会（更新）", held_at: "2026-08-01T19:00:00Z" } } }
        run_test!
      end

      response 404, "イベントが見つからない" do
        schema "$ref" => "#/components/schemas/NotFoundError"
        let!(:id) { SecureRandom.uuid }
        let!(:event) { { event: { event_name: "歓迎会（更新）" } } }
        run_test!
      end

      response 422, "バリデーションエラー" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let!(:id) { Event.create!(event_name: "歓迎会").id }
        let!(:event) { { event: { event_name: "" } } }
        run_test!
      end
    end
  end
end
