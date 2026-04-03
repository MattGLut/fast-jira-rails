class CreateApiTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :api_tokens do |t|
      t.string :token, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_used_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :api_tokens, :token, unique: true
    add_index :api_tokens, :active
  end
end
