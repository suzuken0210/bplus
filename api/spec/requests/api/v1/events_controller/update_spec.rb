require "rails_helper"

# PATCH /api/v1/events/:id の振る舞いテスト。
# OpenAPI 契約（スキーマ）の検証は spec/requests/api/v1/events_spec.rb（rswag）が担う。
# レスポンス形状を変更する際は rswag 側と openapi.yaml も併せて更新すること。
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

  context "event_name のみを部分更新する場合" do
    let!(:event) { Event.create!(event_name: "歓迎会", held_at: Time.zone.parse("2026-08-01T19:00:00Z")) }
    let!(:params) { { event: { event_name: "歓迎会（更新）" } } }

    it "200 を返し、held_at は変更されない", :aggregate_failures do
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
      expect(event.held_at).to eq(Time.zone.parse("2026-08-01T19:00:00Z"))
    end
  end

  context "held_at のみを部分更新する場合" do
    let!(:event) { Event.create!(event_name: "歓迎会") }
    let!(:params) { { event: { held_at: "2026-09-01T10:00:00Z" } } }

    it "200 を返し、event_name は変更されない", :aggregate_failures do
      events_update

      event.reload
      expected_body = {
        "id" => event.id,
        "event_name" => "歓迎会",
        "held_at" => "2026-09-01T10:00:00Z",
        "created_at" => event.created_at.iso8601,
        "updated_at" => event.updated_at.iso8601,
        "discarded_at" => nil
      }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(expected_body)
      expect(event.event_name).to eq("歓迎会")
    end
  end

  context "held_at に null を指定する場合" do
    let!(:event) { Event.create!(event_name: "歓迎会", held_at: Time.zone.parse("2026-08-01T19:00:00Z")) }
    let!(:params) { { event: { held_at: nil } } }

    it "200 を返し、開催日時が未定に戻る", :aggregate_failures do
      events_update

      event.reload
      expected_body = {
        "id" => event.id,
        "event_name" => "歓迎会",
        "held_at" => nil,
        "created_at" => event.created_at.iso8601,
        "updated_at" => event.updated_at.iso8601,
        "discarded_at" => nil
      }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(expected_body)
      expect(event.held_at).to be_nil
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

  context "イベントが論理削除済みの場合" do
    let!(:event) { Event.create!(event_name: "削除済みイベント", discarded_at: Time.current) }
    let!(:params) { { event: { event_name: "歓迎会（更新）" } } }

    it "404 を返し、DB は更新されない", :aggregate_failures do
      events_update

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq({ "error" => "イベントが見つかりません" })
      expect(event.reload.event_name).to eq("削除済みイベント")
    end
  end

  context "event パラメータが無い場合" do
    let!(:event) { Event.create!(event_name: "歓迎会") }
    let!(:params) { {} }

    it "400 を返す" do
      events_update

      expect(response).to have_http_status(:bad_request)
    end
  end
end
