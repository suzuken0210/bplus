require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "name が無いと無効" do
      user = User.new(name: "")
      expect(user).to be_invalid
      expect(user.errors).to be_of_kind(:name, :blank)
    end

    it "name があれば有効" do
      expect(User.new(name: "山田太郎")).to be_valid
    end
  end

  describe "関連" do
    it "user_join_events 経由で events を取得できる" do
      user = User.create!(name: "山田太郎")
      event = Event.create!(event_name: "懇親会")
      UserJoinEvent.create!(user: user, event: event)

      expect(user.events).to contain_exactly(event)
    end

    it "ユーザーを削除すると user_join_events も削除される" do
      user = User.create!(name: "山田太郎")
      event = Event.create!(event_name: "懇親会")
      UserJoinEvent.create!(user: user, event: event)

      expect { user.destroy! }.to change(UserJoinEvent, :count).by(-1)
    end
  end

  describe ".kept" do
    it "論理削除済みを除外する" do
      kept = User.create!(name: "有効ユーザー")
      User.create!(name: "削除済みユーザー", discarded_at: Time.current)

      expect(User.kept).to contain_exactly(kept)
    end
  end
end
