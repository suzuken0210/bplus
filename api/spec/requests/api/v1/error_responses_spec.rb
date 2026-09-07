require "rails_helper"

# ApplicationController の rescue_from によるエラーレスポンス統一の振る舞いテスト。
# 実際のエンドポイント経由で、エラーボディの形式まで検証する。
RSpec.describe "API エラーレスポンス", type: :request do
  describe "ActiveRecord::RecordInvalid（422）" do
    subject(:participations_create) do
      post "/api/v1/events/#{event.id}/participation", params: { user_id: SecureRandom.uuid }, as: :json
    end

    let!(:event) { Event.create!(event_name: "懇親会") }

    it "422 と { errors: [...] } 形式のボディを返す", :aggregate_failures do
      expect { participations_create }.not_to change(UserJoinEvent, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq({ "errors" => [ "User must exist" ] })
    end
  end

  describe "ActionController::ParameterMissing（400）" do
    subject(:events_create) { post "/api/v1/events", params: {}, as: :json }

    it "400 と { error: \"...\" } 形式のボディを返す", :aggregate_failures do
      expect { events_create }.not_to change(Event, :count)
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq({ "error" => "param is missing or the value is empty or invalid: event" })
    end
  end
end
