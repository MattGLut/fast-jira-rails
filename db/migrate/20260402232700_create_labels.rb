class CreateLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :labels do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :labels, %i[project_id name], unique: true
  end
end
