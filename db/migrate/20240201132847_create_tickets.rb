class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.integer :assigned_user_id
      t.date :due_date
      t.integer :ticket_status_id
      t.integer :progress

      t.timestamps
    end

    add_index :tickets, :assigned_user_id
    add_index :tickets, :ticket_status_id

    add_foreign_key :tickets, :users, column: :assigned_user_id
    add_foreign_key :tickets, :ticket_statuses, column: :ticket_status_id
  end
end
