class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.string :message, null: false
      t.boolean :read, null: false, default: false
      t.string :notification_type
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :ticket, null: true, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :notifications, :read
    add_index :notifications, :created_at
  end
end
