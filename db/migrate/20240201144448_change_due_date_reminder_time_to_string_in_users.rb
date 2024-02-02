class ChangeDueDateReminderTimeToStringInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :due_date_reminder_time, :string
  end
end
