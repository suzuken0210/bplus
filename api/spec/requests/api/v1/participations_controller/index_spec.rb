require "rails_helper"

# GET /api/v1/users/:user_id/participations の振る舞いテスト。
RSpec.describe "Api::V1::ParticipationsController GET /api/v1/users/:user_id/participations", type: :request do
  subject(:participations_index) { get "/api/v1/users/#{user.id}/participations" }

  let!(:user) { User.create!(name: "山田太郎") }

  context "参加中のイベントがある場合" do
    let!(:joined_event) { Event.create!(event_name: "懇親会") }
    let!(:cancelled_event) { Event.create!(event_name: "取り消したイベント") }
    let!(:other_user_event) { Event.create!(event_name: "他ユーザーのイベント") }
    let!(:other_user) { User.create!(name: "別のユーザー") }

    before do
      UserJoinEvent.create!(user: user, event: joined_event)
      UserJoinEvent.create!(user: user, event: cancelled_event, discarded_at: Time.current)
      UserJoinEvent.create!(user: other_user, event: other_user_event)
    end

    it "参加中（有効）の参加のみを返す", :aggregate_failures do
      participations_index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([ { "event_id" => joined_event.id } ])
    end
  end

  context "参加中のイベントが無い場合" do
    it "空配列を返す", :aggregate_failures do
      participations_index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end
end
