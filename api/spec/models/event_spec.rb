require "rails_helper"

RSpec.describe Event, type: :model do
  describe "バリデーション" do
    it "event_name が無いと無効" do
      event = Event.new(event_name: "")
      expect(event).to be_invalid
      expect(event.errors).to be_of_kind(:event_name, :blank)
    end

    it "event_name が nil でも無効" do
      event = Event.new(event_name: nil)
      expect(event).to be_invalid
      expect(event.errors).to be_of_kind(:event_name, :blank)
    end

    it "event_name があれば有効" do
      expect(Event.new(event_name: "懇親会")).to be_valid
    end

    it "held_at が無くても有効（開催日時未定のイベント）" do
      expect(Event.new(event_name: "懇親会", held_at: nil)).to be_valid
    end

    it "held_at があっても有効" do
      expect(Event.new(event_name: "懇親会", held_at: Time.zone.parse("2026-08-01T19:00:00Z"))).to be_valid
    end
  end

  describe "作成" do
    it "held_at 付きで作成すると値が保持される" do
      event = Event.create!(event_name: "懇親会", held_at: "2026-08-01T19:00:00Z")

      expect(event.reload.held_at).to eq(Time.zone.parse("2026-08-01T19:00:00Z"))
    end

    it "held_at を指定しなければ nil で作成される" do
      event = Event.create!(event_name: "懇親会")

      expect(event.reload.held_at).to be_nil
    end

    it "日時として解釈できない held_at は nil として扱われる" do
      event = Event.create!(event_name: "懇親会", held_at: "invalid")

      expect(event.reload.held_at).to be_nil
    end
  end

  describe "更新" do
    let!(:event) { Event.create!(event_name: "懇親会", held_at: "2026-08-01T19:00:00Z") }

    it "event_name を更新できる" do
      expect(event.update(event_name: "懇親会（更新）")).to be true
      expect(event.reload.event_name).to eq("懇親会（更新）")
    end

    it "event_name を空に更新すると無効で、DB は変更されない" do
      expect(event.update(event_name: "")).to be false
      expect(event.errors).to be_of_kind(:event_name, :blank)
      expect(event.reload.event_name).to eq("懇親会")
    end

    it "held_at を更新できる" do
      expect(event.update(held_at: "2026-09-01T10:00:00Z")).to be true
      expect(event.reload.held_at).to eq(Time.zone.parse("2026-09-01T10:00:00Z"))
    end

    it "held_at を nil に更新して未定に戻せる" do
      expect(event.update(held_at: nil)).to be true
      expect(event.reload.held_at).to be_nil
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
