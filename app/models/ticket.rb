class Ticket < ApplicationRecord
  belongs_to :assignee, class_name: 'User', foreign_key: 'assigned_user_id'
  belongs_to :status, class_name: 'TicketStatus', foreign_key: 'ticket_status_id'
  has_many :reminders, dependent: :destroy

  before_validation :set_default_status
  before_create :create_reminders
  before_update :regenerate_reminders, if: -> { assignee_changed? }

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :due_date
  validates_presence_of :assignee
  validates_presence_of :status

  def regenerate_reminders
    reminders.destroy_all
    create_reminders
  end

  private

  def set_default_status
    self.ticket_status_id = self.ticket_status_id.presence || TicketStatus.find_or_create_by(name: TicketStatus::STATUSES[:draft]).id
  end

  def create_reminders
    return unless reminder_ids.empty?
    return unless assignee.send_due_date_reminder

    self.reminder_ids = Reminders::Manager.create_reminders_for(self).map(&:id)
  end
end
