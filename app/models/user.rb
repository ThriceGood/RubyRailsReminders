class User < ApplicationRecord
  has_many :tickets, foreign_key: :assigned_user_id, dependent: :nullify

  after_update :regenerate_reminders, if: -> { reminder_settings_changed? }
  after_update :initialize_reminders, if: -> { saved_change_to_send_due_date_reminder? }

  validates_presence_of :name
  validates_presence_of :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates_presence_of :due_date_reminder_day_offset, if: -> { send_due_date_reminder }
  validates_presence_of :due_date_reminder_interval, if: -> { send_due_date_reminder }
  validates_presence_of :due_date_reminder_time, if: -> { send_due_date_reminder }
  validates_presence_of :time_zone, if: -> { send_due_date_reminder }

  validate :validate_configured_reminder_types

  private

  def validate_configured_reminder_types
    invalid_types = configured_reminder_types - Reminders::Manager::REMINDER_TYPES
    errors.add(:configured_reminder_types, "Invalid reminder types: #{invalid_types.join(', ')}") if invalid_types.any?
  end

  def reminder_settings_changed?
    return true if saved_change_to_due_date_reminder_day_offset?
    return true if saved_change_to_due_date_reminder_interval?
    return true if saved_change_to_due_date_reminder_time?
    return true if saved_change_to_time_zone?
  end

  def regenerate_reminders
    tickets.each { |ticket| ticket.regenerate_reminders }
  end

  def initialize_reminders
    if send_due_date_reminder
      regenerate_reminders
    else
      tickets.each { |ticket| ticket.reminders.destroy_all }
    end
  end
end
