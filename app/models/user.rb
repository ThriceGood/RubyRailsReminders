class User < ApplicationRecord
  has_many :tickets, foreign_key: :assigned_user_id, dependent: :nullify

  validates_presence_of :name
  validates_presence_of :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :validate_configured_reminder_types

  # gets users who have tickets that require reminders to be send out
  # returns the users with their specific remindable emails only
  # will return tickets the user defined offest number of days before ticket due date
  # will be called by the scheduler at beginning of every day at 00:00:00
  scope :with_active_reminder_tickets, -> {
    includes(tickets: :status)
      .where(send_due_date_reminder: true)
      .where(status: { id: TicketStatus.find_by(name: TicketStatus::STATUSES[:active]) })
      .where('CURRENT_DATE <= tickets.due_date')
      .where('CURRENT_DATE = (tickets.due_date - users.due_date_reminder_day_offset)')
  }

  private

  def validate_configured_reminder_types
    invalid_types = configured_reminder_types - Reminders::Manager::REMINDER_TYPES
    errors.add(:configured_reminder_types, "Invalid reminder types: #{invalid_types.join(', ')}") if invalid_types.any?
  end
end
