require "rails_helper"

# POST /api/v1/events/:event_id/participation の振る舞いテスト。
RSpec.describe "Api::V1::ParticipationsController POST /api/v1/events/:event_id/participation", type: :request do
  subject(:participations_create) do
    post "/api/v1/events/#{event.id}/participation", params: { user_id: user.id }, as: :json
  end

  let!(:user) { User.create!(name: "山田太郎") }
  let!(:event) { Event.create!(event_name: "懇親会") }

  context "未参加の場合" do
    it "参加が1件作成される" do
      expect { participations_create }.to change(UserJoinEvent.kept, :count).by(1)
    end

    it "201 と event_id を返す", :aggregate_failures do
      participations_create

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq({ "event_id" => event.id })
    end
  end

  context "既に参加中の場合（冪等）" do
    before { UserJoinEvent.create!(user: user, event: event) }

    it "参加レコードは増えない" do
      expect { participations_create }.not_to change(UserJoinEvent, :count)
    end

    it "200 と event_id を返す", :aggregate_failures do
      participations_create

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ "event_id" => event.id })
    end
  end

  context "参加を取り消し済みの場合" do
    let!(:cancelled_participation) do
      UserJoinEvent.create!(user: user, event: event, discarded_at: Time.current)
    end

    it "取り消し済みの参加が復活し、レコードは増えない", :aggregate_failures do
      expect { participations_create }.not_to change(UserJoinEvent, :count)
      expect(cancelled_participation.reload.discarded_at).to be_nil
    end

    it "201 と event_id を返す", :aggregate_failures do
      participations_create

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq({ "event_id" => event.id })
    end
  end

  context "user_id が存在しないユーザーの場合" do
    subject(:participations_create) do
      post "/api/v1/events/#{event.id}/participation", params: { user_id: SecureRandom.uuid }, as: :json
    end

    it "422 を返し、参加は作成されない", :aggregate_failures do
      expect { participations_create }.not_to change(UserJoinEvent, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
