require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "event_name が無いと無効" do
    event = Event.new(event_name: "")
    assert_predicate event, :invalid?
    assert event.errors.of_kind?(:event_name, :blank)
  end

  test "event_name があれば有効" do
    event = Event.new(event_name: "懇親会")
    assert_predicate event, :valid?
  end

  test "kept スコープは論理削除済みを除外する" do
    kept = Event.create!(event_name: "有効イベント")
    Event.create!(event_name: "削除済み", discarded_at: Time.current)

    assert_includes Event.kept, kept
    assert_equal 1, Event.kept.count
  end
end
