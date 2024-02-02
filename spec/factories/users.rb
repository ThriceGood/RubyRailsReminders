FactoryBot.define do
  factory :user do
    name { "Josh Smith" }
    sequence :email do |n|
      "user#{n}@example.com"
    end
    send_due_date_reminder { true }
    due_date_reminder_day_offset { 1 }
    due_date_reminder_time { "09:00:00" }
    due_date_reminder_interval { 1 }
    time_zone { "Europe/Vienna" }
  end
end
