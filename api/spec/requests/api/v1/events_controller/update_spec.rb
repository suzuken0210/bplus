require "rails_helper"

# PATCH /api/v1/events/:id の振る舞いテスト（最小限）。
# OpenAPI 契約（スキーマ）の検証は spec/requests/api/v1/events_spec.rb（rswag）が担う。
# 網羅的なケース（部分更新・400 など）は別タスクで追加する。
RSpec.describe "Api::V1::EventsController PATCH /api/v1/events/:id", type: :request do
  subject(:events_update) { patch "/api/v1/events/#{event_id}", params: params, as: :json }

  let!(:event_id) { event.id }

  context "有効なパラメータの場合" do
    let!(:event) { Event.create!(event_name: "歓迎会") }
    let!(:params) { { event: { event_name: "歓迎会（更新）", held_at: "2026-08-01T19:00:00Z" } } }

    it "200 と更新後のイベントを返し、DB も更新される", :aggregate_failures do
      events_update

      event.reload
      expected_body = {
        "id" => event.id,
        "event_name" => "歓迎会（更新）",
        "held_at" => "2026-08-01T19:00:00Z",
        "created_at" => event.created_at.iso8601,
        "updated_at" => event.updated_at.iso8601,
        "discarded_at" => nil
      }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(expected_body)
      expect(event.event_name).to eq("歓迎会（更新）")
      expect(event.held_at).to eq(Time.zone.parse("2026-08-01T19:00:00Z"))
    end
  end

  context "event_name が空の場合" do
    let!(:event) { Event.create!(event_name: "歓迎会") }
    let!(:params) { { event: { event_name: "" } } }

    it "422 とエラーメッセージを返し、DB は更新されない", :aggregate_failures do
      events_update

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq({ "errors" => [ "Event name can't be blank" ] })
      expect(event.reload.event_name).to eq("歓迎会")
    end
  end

  context "イベントが存在しない場合" do
    let!(:event_id) { SecureRandom.uuid }
    let!(:params) { { event: { event_name: "歓迎会（更新）" } } }

    it "404 を返す", :aggregate_failures do
      events_update

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq({ "error" => "イベントが見つかりません" })
    end
  end
end
