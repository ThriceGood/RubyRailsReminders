class CreateTicketStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_statuses do |t|
      t.string :name
    end

    add_index :ticket_statuses, :name, unique: true
  end
end
