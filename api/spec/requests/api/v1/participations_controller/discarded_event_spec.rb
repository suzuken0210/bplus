require "rails_helper"

# 論理削除済み・存在しないイベントに対する参加 API の振る舞いテスト。
RSpec.describe "Api::V1::ParticipationsController 論理削除済みイベントの扱い", type: :request do
  let!(:user) { User.create!(name: "山田太郎") }
  let!(:discarded_event) { Event.create!(event_name: "削除済みイベント", discarded_at: Time.current) }

  describe "POST /api/v1/events/:event_id/participation" do
    context "イベントが論理削除済みの場合" do
      subject(:participations_create) do
        post "/api/v1/events/#{discarded_event.id}/participation", params: { user_id: user.id }, as: :json
      end

      it "404 を返し、参加は作成されない", :aggregate_failures do
        expect { participations_create }.not_to change(UserJoinEvent, :count)
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq({ "error" => "イベントが見つかりません" })
      end
    end

    context "イベントが存在しない場合" do
      subject(:participations_create) do
        post "/api/v1/events/#{SecureRandom.uuid}/participation", params: { user_id: user.id }, as: :json
      end

      it "404 を返し、参加は作成されない", :aggregate_failures do
        expect { participations_create }.not_to change(UserJoinEvent, :count)
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq({ "error" => "イベントが見つかりません" })
      end
    end
  end

  describe "GET /api/v1/users/:user_id/participations" do
    subject(:participations_index) { get "/api/v1/users/#{user.id}/participations" }

    context "参加中のイベントが論理削除済みの場合" do
      let!(:kept_event) { Event.create!(event_name: "有効イベント") }

      before do
        UserJoinEvent.create!(user: user, event: kept_event)
        UserJoinEvent.create!(user: user, event: discarded_event)
      end

      it "論理削除済みイベントの参加は含めない", :aggregate_failures do
        participations_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([ { "event_id" => kept_event.id } ])
      end
    end
  end
end
