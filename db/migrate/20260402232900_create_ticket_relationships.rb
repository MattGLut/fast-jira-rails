class CreateTicketRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_relationships do |t|
      t.references :source_ticket, null: false, foreign_key: { to_table: :tickets }
      t.references :target_ticket, null: false, foreign_key: { to_table: :tickets }
      t.integer :relationship_type, null: false

      t.timestamps
    end

    add_index :ticket_relationships,
              %i[source_ticket_id target_ticket_id relationship_type],
              unique: true,
              name: "idx_ticket_relationship_uniqueness"
  end
end
