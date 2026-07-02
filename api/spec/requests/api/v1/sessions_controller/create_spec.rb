require "rails_helper"

# POST /api/v1/login（モックログイン）の振る舞いテスト。
RSpec.describe "Api::V1::SessionsController POST /api/v1/login", type: :request do
  subject(:login) { post "/api/v1/login", params: { name: name }, as: :json }

  let!(:user) { User.create!(name: "山田太郎") }

  context "name が一致する有効なユーザーがいる場合" do
    let!(:name) { "山田太郎" }

    it "200 とユーザー情報を返す", :aggregate_failures do
      login

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ "id" => user.id, "name" => "山田太郎" })
    end
  end

  context "name が一致するユーザーが論理削除済みの場合" do
    let!(:name) { "削除済みユーザー" }

    before { User.create!(name: "削除済みユーザー", discarded_at: Time.current) }

    it "404 を返す", :aggregate_failures do
      login

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("該当するユーザーが見つかりません")
    end
  end

  context "name が一致するユーザーがいない場合" do
    let!(:name) { "存在しないユーザー" }

    it "404 を返す", :aggregate_failures do
      login

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("該当するユーザーが見つかりません")
    end
  end

  context "name が未指定の場合" do
    subject(:login) { post "/api/v1/login", params: {}, as: :json }

    it "404 を返す" do
      login

      expect(response).to have_http_status(:not_found)
    end
  end
end
