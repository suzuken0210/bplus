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

  describe ".kept" do
    it "論理削除済みを除外する" do
      kept = Event.create!(event_name: "有効イベント")
      Event.create!(event_name: "削除済み", discarded_at: Time.current)

      expect(Event.kept).to include(kept)
      expect(Event.kept.count).to eq(1)
    end
  end
end
