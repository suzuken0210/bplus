require "swagger_helper"

# このファイルは「events API のテスト」と「openapi.yaml の生成元」を兼ねる。
# rake rswag:specs:swaggerize で api/openapi.yaml が生成される。
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
        let!(:event) { { event: { event_name: "歓迎会" } } }
        run_test!
      end

      response 422, "バリデーションエラー" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let!(:event) { { event: { event_name: "" } } }
        run_test!
      end
    end
  end
end
