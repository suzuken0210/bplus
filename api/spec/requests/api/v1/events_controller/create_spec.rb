require "rails_helper"

# POST /api/v1/events の振る舞いテスト。
# OpenAPI 契約（スキーマ）の検証は spec/requests/api/v1/events_spec.rb（rswag）が担う。
# レスポンス形状を変更する際は rswag 側と openapi.yaml も併せて更新すること。
RSpec.describe "Api::V1::EventsController POST /api/v1/events", type: :request do
  subject(:events_create) { post "/api/v1/events", params: params, as: :json }

  context "有効なパラメータの場合" do
    let!(:params) { { event: { event_name: "歓迎会" } } }

    it "イベントが1件作成される" do
      expect { events_create }.to change(Event, :count).by(1)
    end

    it "201 と作成したイベントを返す", :aggregate_failures do
      events_create

      # 作成順ソートは同時刻レコードで不安定なため、レスポンスの id で作成レコードを特定する。
      created_event = Event.find(response.parsed_body.fetch("id"))
      expected_body = {
        "id" => created_event.id,
        "event_name" => "歓迎会",
        "held_at" => nil,
        "created_at" => created_event.created_at.iso8601,
        "updated_at" => created_event.updated_at.iso8601,
        "discarded_at" => nil
      }
      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq(expected_body)
    end
  end

  context "held_at を指定した場合" do
    let!(:params) { { event: { event_name: "歓迎会", held_at: "2026-08-01T19:00:00Z" } } }

    it "201 と held_at を含むイベントを返す", :aggregate_failures do
      events_create

      created_event = Event.find(response.parsed_body.fetch("id"))
      expected_body = {
        "id" => created_event.id,
        "event_name" => "歓迎会",
        "held_at" => "2026-08-01T19:00:00Z",
        "created_at" => created_event.created_at.iso8601,
        "updated_at" => created_event.updated_at.iso8601,
        "discarded_at" => nil
      }
      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq(expected_body)
      expect(created_event.held_at).to eq(Time.zone.parse("2026-08-01T19:00:00Z"))
    end
  end

  context "held_at が日時として解釈できない場合" do
    let!(:params) { { event: { event_name: "歓迎会", held_at: "invalid" } } }

    it "201 を返し、held_at は nil として作成される", :aggregate_failures do
      events_create

      created_event = Event.find(response.parsed_body.fetch("id"))
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.fetch("held_at")).to be_nil
      expect(created_event.held_at).to be_nil
    end
  end

  context "未許可のパラメータを含む場合" do
    let!(:params) { { event: { event_name: "歓迎会", discarded_at: Time.current.iso8601 } } }

    it "未許可のパラメータは無視して作成される", :aggregate_failures do
      events_create

      created_event = Event.find(response.parsed_body.fetch("id"))
      expect(response).to have_http_status(:created)
      expect(created_event.discarded_at).to be_nil
    end
  end

  context "event_name が空の場合" do
    let!(:params) { { event: { event_name: "" } } }

    it "イベントは作成されない" do
      expect { events_create }.not_to change(Event, :count)
    end

    it "422 とエラーメッセージを返す", :aggregate_failures do
      events_create

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq({ "errors" => [ "Event name can't be blank" ] })
    end
  end

  context "event パラメータが無い場合" do
    let!(:params) { {} }

    it "400 を返す" do
      events_create

      expect(response).to have_http_status(:bad_request)
    end
  end

  context "event パラメータが空の場合" do
    let!(:params) { { event: {} } }

    it "400 を返す" do
      events_create

      expect(response).to have_http_status(:bad_request)
    end
  end
end
