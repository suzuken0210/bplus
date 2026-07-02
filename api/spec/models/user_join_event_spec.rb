require "rails_helper"

RSpec.describe UserJoinEvent, type: :model do
  let!(:user) { User.create!(name: "山田太郎") }
  let!(:event) { Event.create!(event_name: "懇親会") }

  describe "DB 制約" do
    it "同一ユーザー・同一イベントの有効な参加は重複登録できない" do
      UserJoinEvent.create!(user: user, event: event)

      expect {
        UserJoinEvent.create!(user: user, event: event)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "取り消し済みの参加があれば同じ組み合わせで再登録できる" do
      UserJoinEvent.create!(user: user, event: event, discarded_at: Time.current)

      expect {
        UserJoinEvent.create!(user: user, event: event)
      }.to change(UserJoinEvent, :count).by(1)
    end
  end

  describe ".kept" do
    it "論理削除済みを除外する" do
      kept = UserJoinEvent.create!(user: user, event: event)
      other_event = Event.create!(event_name: "忘年会")
      UserJoinEvent.create!(user: user, event: other_event, discarded_at: Time.current)

      expect(UserJoinEvent.kept).to contain_exactly(kept)
    end
  end
end
