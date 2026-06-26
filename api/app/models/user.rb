class User < ApplicationRecord
  # name は必須。
  validates :name, presence: true

  # 参加中間テーブル経由でイベントと多対多。
  has_many :user_join_events, dependent: :destroy
  has_many :events, through: :user_join_events

  # 有効なユーザー（論理削除されていない）のみ。
  scope :kept, -> { where(discarded_at: nil) }
end
