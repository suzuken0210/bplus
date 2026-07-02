require "rails_helper"

# DELETE /api/v1/events/:event_id/participation の振る舞いテスト。
RSpec.describe "Api::V1::ParticipationsController DELETE /api/v1/events/:event_id/participation", type: :request do
  subject(:participations_destroy) do
    delete "/api/v1/events/#{event.id}/participation", params: { user_id: user.id }, as: :json
  end

  let!(:user) { User.create!(name: "山田太郎") }
  let!(:event) { Event.create!(event_name: "懇親会") }

  context "参加中の場合" do
    let!(:participation) { UserJoinEvent.create!(user: user, event: event) }

    it "204 を返し、参加が論理削除される", :aggregate_failures do
      participations_destroy

      expect(response).to have_http_status(:no_content)
      expect(participation.reload.discarded_at).to be_present
    end

    it "物理削除はされない" do
      expect { participations_destroy }.not_to change(UserJoinEvent, :count)
    end
  end

  context "既に取り消し済みの場合（冪等）" do
    let!(:participation) do
      UserJoinEvent.create!(user: user, event: event, discarded_at: 1.day.ago)
    end

    it "204 を返し、取り消し日時は変わらない", :aggregate_failures do
      expect { participations_destroy }.not_to change { participation.reload.discarded_at }
      expect(response).to have_http_status(:no_content)
    end
  end

  context "参加していない場合（冪等）" do
    it "204 を返す" do
      participations_destroy

      expect(response).to have_http_status(:no_content)
    end
  end
end
