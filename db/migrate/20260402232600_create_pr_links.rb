class CreatePrLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :pr_links do |t|
      t.string :url, null: false
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :pr_links, :status
  end
end
