class AddHeldAtToEvents < ActiveRecord::Migration[8.1]
  def change
    # 開催日時。既存レコードがあるため NULL を許可する（未定のイベントも想定）。
    add_column :events, :held_at, :datetime
  end
end
