class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    # PostgreSQL 13+ では gen_random_uuid() が標準提供のため拡張は不要。
    create_table :events, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :event_name, null: false
      t.datetime :discarded_at # 論理削除用（NULL なら有効）

      t.timestamps
    end

    add_index :events, :discarded_at
  end
end
