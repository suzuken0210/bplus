class UserJoinEvent < ApplicationRecord
  belongs_to :user
  belongs_to :event

  # 有効な参加（論理削除されていない）のみ。
  scope :kept, -> { where(discarded_at: nil) }
end
