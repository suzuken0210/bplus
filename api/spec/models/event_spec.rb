require "rails_helper"

RSpec.describe Event, type: :model do
  describe "バリデーション" do
    it "event_name が無いと無効" do
      event = Event.new(event_name: "")
      expect(event).to be_invalid
      expect(event.errors).to be_of_kind(:event_name, :blank)
    end

    it "event_name があれば有効" do
      expect(Event.new(event_name: "懇親会")).to be_valid
    end
  end

  describe "関連" do
    it "user_join_events 経由で users を取得できる" do
      event = Event.create!(event_name: "懇親会")
      user = User.create!(name: "山田太郎")
      UserJoinEvent.create!(user: user, event: event)

      expect(event.users).to contain_exactly(user)
    end

    it "イベントを削除すると user_join_events も削除される" do
      event = Event.create!(event_name: "懇親会")
      user = User.create!(name: "山田太郎")
      UserJoinEvent.create!(user: user, event: event)

      expect { event.destroy! }.to change(UserJoinEvent, :count).by(-1)
    end
  end

  describe ".kept" do
    it "論理削除済みを除外する" do
      kept = Event.create!(event_name: "有効イベント")
      Event.create!(event_name: "削除済み", discarded_at: Time.current)

      expect(Event.kept).to include(kept)
      expect(Event.kept.count).to eq(1)
    end
  end
end
