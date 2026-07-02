require "rails_helper"

# GET /api/v1/events の振る舞いテスト。
# OpenAPI 契約（スキーマ）の検証は spec/requests/api/v1/events_spec.rb（rswag）が担う。
RSpec.describe "Api::V1::EventsController GET /api/v1/events", type: :request do
  subject(:events_index) { get "/api/v1/events" }

  context "イベントが存在する場合" do
    let!(:older_event) { Event.create!(event_name: "歓迎会", created_at: 2.days.ago) }
    let!(:newer_event) { Event.create!(event_name: "忘年会", created_at: 1.day.ago) }
    let!(:discarded_event) { Event.create!(event_name: "削除済みイベント", discarded_at: Time.current) }

    it "有効なイベントのみを作成順（古い順）で返す", :aggregate_failures do
      events_index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |event| event["id"] }).to eq([ older_event.id, newer_event.id ])
    end

    it "イベントの属性を返す", :aggregate_failures do
      events_index

      event = response.parsed_body.first
      expect(event["id"]).to eq(older_event.id)
      expect(event["event_name"]).to eq("歓迎会")
      expect(event["created_at"]).to eq(older_event.created_at.iso8601)
      expect(event["updated_at"]).to eq(older_event.updated_at.iso8601)
      expect(event["discarded_at"]).to be_nil
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
