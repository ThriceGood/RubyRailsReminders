# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

TicketStatus.create(name: :draft)
TicketStatus.create(name: :inactive)
active_status = TicketStatus.create(name: :active)
TicketStatus.create(name: :complete)

user = User.create(
  name: 'Josh Smith',
  email: 'josh@example.com',
  send_due_date_reminder: true,
  due_date_reminder_day_offset: 1,
  due_date_reminder_time: '10:00:00',
  due_date_reminder_interval: 1,
  time_zone: 'Europe/Vienna'
)

Ticket.create(
  title: 'Example Ticket',
  description: 'This is an example ticket description.',
  assigned_user_id: user.id,
  due_date: Date.current + 1.day,
  ticket_status_id: active_status.id
)