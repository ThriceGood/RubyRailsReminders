class Ticket < ApplicationRecord
  belongs_to :assignee, class_name: 'User', foreign_key: 'assigned_user_id'
  belongs_to :status, class_name: 'TicketStatus', foreign_key: 'ticket_status_id'

  before_validation :set_default_status

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :due_date
  validates_presence_of :assignee
  validates_presence_of :status

  private

  def set_default_status
    self.ticket_status_id = self.ticket_status_id.presence || TicketStatus.find_or_create_by(name: TicketStatus::STATUSES[:draft]).id
  end
end
