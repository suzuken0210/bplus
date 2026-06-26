class Event < ApplicationRecord
  # event_name は必須。
  validates :event_name, presence: true

  # 参加中間テーブル経由でユーザーと多対多。
  has_many :user_join_events, dependent: :destroy
  has_many :users, through: :user_join_events

  # 有効なイベント（論理削除されていない）のみ。
  scope :kept, -> { where(discarded_at: nil) }
end
