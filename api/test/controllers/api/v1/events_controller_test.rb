require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  test "index は kept なイベントを作成順（古い順）で返す" do
    old = Event.create!(event_name: "古いイベント")
    old.update_column(:created_at, 2.days.ago)
    recent = Event.create!(event_name: "新しいイベント")
    recent.update_column(:created_at, 1.day.ago)
    Event.create!(event_name: "削除済み", discarded_at: Time.current)

    get "/api/v1/events"

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body.size
    assert_equal [ old.id, recent.id ], body.map { |e| e["id"] }
    assert_equal %w[id event_name created_at updated_at discarded_at].sort, body.first.keys.sort
  end

  test "create は event を追加して 201 を返す" do
    assert_difference -> { Event.count }, 1 do
      post "/api/v1/events", params: { event: { event_name: "歓迎会" } }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "歓迎会", body["event_name"]
  end

  test "create は event_name が無いと 422 を返す" do
    assert_no_difference -> { Event.count } do
      post "/api/v1/events", params: { event: { event_name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].present?
  end
end
