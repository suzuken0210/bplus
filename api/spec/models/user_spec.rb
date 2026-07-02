require "rails_helper"

RSpec.describe User, type: :model do
  describe ".kept" do
    it "論理削除済みを除外する" do
      kept = User.create!(name: "有効ユーザー")
      User.create!(name: "削除済みユーザー", discarded_at: Time.current)

      expect(User.kept).to contain_exactly(kept)
    end
  end
end
