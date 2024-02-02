class AddDefaultFalseValueToUsersSendDueDateReminderField < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :send_due_date_reminder, false
  end
end
