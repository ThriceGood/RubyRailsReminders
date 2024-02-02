class TicketStatus < ApplicationRecord
  STATUSES = {
    draft: 'draft',
    inactive: 'inactive',
    active: 'active',
    complete: 'complete'
  }.freeze

  has_many :tickets

  validates :name, inclusion: { in: STATUSES.keys.map(&:to_s) }
end
