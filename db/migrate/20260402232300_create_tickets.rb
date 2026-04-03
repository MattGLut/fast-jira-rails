class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.integer :ticket_type, null: false
      t.integer :story_points
      t.date :due_date
      t.integer :ticket_number, null: false
      t.references :project, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tickets, %i[project_id ticket_number], unique: true
    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :ticket_type
  end
end
