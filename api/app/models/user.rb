class User < ApplicationRecord
  # name は必須。
  validates :name, presence: true

  # 有効なユーザー（論理削除されていない）のみ。
  scope :kept, -> { where(discarded_at: nil) }
end
