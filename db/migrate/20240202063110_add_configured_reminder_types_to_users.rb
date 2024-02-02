class AddConfiguredReminderTypesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :configured_reminder_types, :string, array:true, default: ['email']
  end
end
