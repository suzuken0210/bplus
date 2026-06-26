class CreateUserJoinEvents < ActiveRecord::Migration[8.1]
  def change
    # User と Event の多対多（誰がどのイベントに参加しているか）を管理する中間テーブル。
    create_table :user_join_events, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :event, type: :uuid, null: false, foreign_key: true
      t.datetime :discarded_at # 論理削除用（NULL なら有効）

      t.timestamps
    end

    add_index :user_join_events, :discarded_at

    # 有効な参加（discarded_at IS NULL）について、同一 user × event の重複を禁止する。
    add_index :user_join_events, [ :user_id, :event_id ],
      unique: true,
      where: "discarded_at IS NULL",
      name: "index_user_join_events_on_user_event_active"
  end
end
