FactoryBot.define do
  factory :ticket do
    sequence :title do |n|
      "Ticket #{n}"
    end
    description { 'A ticket' }
    assignee { create(:user) }
    due_date { Date.current + 10.days }
    status { TicketStatus.find_or_create_by(name: TicketStatus::STATUSES[:active]) }
  end
end
