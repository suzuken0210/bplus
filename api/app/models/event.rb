class Event < ApplicationRecord
  # event_name は必須。
  validates :event_name, presence: true

  # 有効なイベント（論理削除されていない）のみ。
  scope :kept, -> { where(discarded_at: nil) }
end
