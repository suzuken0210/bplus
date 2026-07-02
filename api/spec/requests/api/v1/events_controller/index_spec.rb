require "rails_helper"

# GET /api/v1/events の振る舞いテスト。
# OpenAPI 契約（スキーマ）の検証は spec/requests/api/v1/events_spec.rb（rswag）が担う。
RSpec.describe "Api::V1::EventsController GET /api/v1/events", type: :request do
  subject(:events_index) { get "/api/v1/events" }

  context "イベントが存在する場合" do
    let!(:older_event) { Event.create!(event_name: "歓迎会", created_at: 2.days.ago) }
    let!(:newer_event) { Event.create!(event_name: "忘年会", created_at: 1.day.ago) }
    let!(:discarded_event) { Event.create!(event_name: "削除済みイベント", discarded_at: Time.current) }

    let!(:expected_body) do
      [
        {
          "id" => older_event.id,
          "event_name" => "歓迎会",
          "created_at" => older_event.created_at.iso8601,
          "updated_at" => older_event.updated_at.iso8601,
          "discarded_at" => nil
        },
        {
          "id" => newer_event.id,
          "event_name" => "忘年会",
          "created_at" => newer_event.created_at.iso8601,
          "updated_at" => newer_event.updated_at.iso8601,
          "discarded_at" => nil
        }
      ]
    end

    it "有効なイベントのみを作成順（古い順）で返す", :aggregate_failures do
      events_index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(expected_body)
    end
  end

  context "イベントが存在しない場合" do
    it "空配列を返す", :aggregate_failures do
      events_index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end
end
