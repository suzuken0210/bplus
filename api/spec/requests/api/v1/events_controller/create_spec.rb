require "rails_helper"

# POST /api/v1/events の振る舞いテスト。
RSpec.describe "Api::V1::EventsController POST /api/v1/events", type: :request do
  subject(:events_create) { post "/api/v1/events", params: params, as: :json }

  context "有効なパラメータの場合" do
    let(:params) { { event: { event_name: "歓迎会" } } }

    it "イベントが1件作成される" do
      expect { events_create }.to change(Event, :count).by(1)
    end

    it "201 と作成したイベントを返す", :aggregate_failures do
      events_create

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["event_name"]).to eq("歓迎会")
      expect(body["id"]).to eq(Event.last.id)
      expect(body["discarded_at"]).to be_nil
    end
  end

  context "event_name が空の場合" do
    let(:params) { { event: { event_name: "" } } }

    it "イベントは作成されない" do
      expect { events_create }.not_to change(Event, :count)
    end

    it "422 とエラーメッセージを返す", :aggregate_failures do
      events_create

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  context "event パラメータが無い場合" do
    let(:params) { {} }

    it "400 を返す" do
      events_create

      expect(response).to have_http_status(:bad_request)
    end
  end
end
