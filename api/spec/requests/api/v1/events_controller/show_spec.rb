require "rails_helper"

# GET /api/v1/events/:id の振る舞いテスト。
RSpec.describe "Api::V1::EventsController GET /api/v1/events/:id", type: :request do
  subject(:events_show) { get "/api/v1/events/#{event_id}" }

  let!(:event) { Event.create!(event_name: "懇親会") }
  let(:event_id) { event.id }

  context "参加者がいる場合" do
    let!(:older_user) { User.create!(name: "先に登録したユーザー", created_at: 2.days.ago) }
    let!(:newer_user) { User.create!(name: "後に登録したユーザー", created_at: 1.day.ago) }

    before do
      UserJoinEvent.create!(user: newer_user, event: event)
      UserJoinEvent.create!(user: older_user, event: event)
    end

    it "イベントと参加者一覧（ユーザー作成順）を返す", :aggregate_failures do
      events_show

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["id"]).to eq(event.id)
      expect(body["event_name"]).to eq("懇親会")
      expect(body["participants"]).to eq([
        { "id" => older_user.id, "name" => older_user.name },
        { "id" => newer_user.id, "name" => newer_user.name }
      ])
    end
  end

  context "参加を取り消したユーザー・論理削除済みユーザーがいる場合" do
    let!(:active_user) { User.create!(name: "参加中ユーザー") }
    let!(:cancelled_user) { User.create!(name: "取り消し済みユーザー") }
    let!(:discarded_user) { User.create!(name: "削除済みユーザー", discarded_at: Time.current) }

    before do
      UserJoinEvent.create!(user: active_user, event: event)
      UserJoinEvent.create!(user: cancelled_user, event: event, discarded_at: Time.current)
      UserJoinEvent.create!(user: discarded_user, event: event)
    end

    it "有効な参加中ユーザーのみを participants に含める", :aggregate_failures do
      events_show

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["participants"]).to eq([
        { "id" => active_user.id, "name" => active_user.name }
      ])
    end
  end

  context "参加者がいない場合" do
    it "participants は空配列になる", :aggregate_failures do
      events_show

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["participants"]).to eq([])
    end
  end

  context "イベントが論理削除済みの場合" do
    let!(:event) { Event.create!(event_name: "削除済みイベント", discarded_at: Time.current) }

    it "404 を返す", :aggregate_failures do
      events_show

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("イベントが見つかりません")
    end
  end

  context "イベントが存在しない場合" do
    let(:event_id) { SecureRandom.uuid }

    it "404 を返す", :aggregate_failures do
      events_show

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("イベントが見つかりません")
    end
  end
end
