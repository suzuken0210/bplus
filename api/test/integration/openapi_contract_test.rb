require "test_helper"
require "committee/rails/test/methods"

# 実装のレスポンスが openapi.yaml の定義に一致するかを検証する契約テスト。
class OpenapiContractTest < ActionDispatch::IntegrationTest
  include Committee::Rails::Test::Methods

  def committee_options
    @committee_options ||= {
      schema_path: Rails.root.join("openapi.yaml").to_s,
      prefix: "/api/v1",
      query_hash_key: "rack.request.query_hash",
      parse_response_by_content_type: true,
      strict_reference_validation: true
    }
  end

  test "GET /api/v1/events のレスポンスが OpenAPI 定義に準拠する" do
    Event.create!(event_name: "契約テスト用イベント")

    get "/api/v1/events"

    assert_response :success
    assert_response_schema_confirm(200)
  end

  test "POST /api/v1/events のレスポンスが OpenAPI 定義に準拠する" do
    post "/api/v1/events", params: { event: { event_name: "新規イベント" } }, as: :json

    assert_response :created
    assert_response_schema_confirm(201)
  end
end
