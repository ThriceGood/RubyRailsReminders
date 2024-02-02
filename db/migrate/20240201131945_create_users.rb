class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :send_due_date_reminder, comment: "Flag to send ticket due date reminders"
      t.integer :due_date_reminder_day_offset, comment: "Days before a ticket's due date to send reminders"
      t.time :due_date_reminder_time, comment: "Time of day user wishes to receive reminder email"
      t.integer :due_date_reminder_interval, comment: "Daily interval to receive reminders before due date"
      t.string :time_zone

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
