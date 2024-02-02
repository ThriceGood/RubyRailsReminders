require 'rails_helper'

RSpec.describe Ticket, type: :model do
  
  describe 'ticket associations' do
    it 'must have associations correctly set up' do
    
      ticket = create(:ticket)

      expect(ticket.assignee).not_to be_nil
      expect(ticket.status).not_to be_nil
    end
  end

  describe 'ticket validations' do

    it 'must create ticket when valid' do

      user = create(:user)
      status = create_ticket_status('active')

      ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        assignee: user, 
        status: status, 
        due_date: Date.tomorrow
      )

      expect(ticket.id).not_to be_nil
      expect(ticket.errors).to be_empty
    end

    it 'must not create ticket without due date' do
    
      user = create(:user)
      status = create_ticket_status('active')

      ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        assignee: user, 
        status: status, 
      )
    
      expect(ticket.id).to be_nil
      expect(ticket.errors).not_to be_empty
      expect(ticket.errors.first.attribute).to eq(:due_date)
    end

    it 'must not create ticket without assignee' do
    
      status = create_ticket_status('active')

      ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        status: status, 
        due_date: Date.tomorrow
      )
    
      expect(ticket.id).to be_nil
      expect(ticket.errors).not_to be_empty
      expect(ticket.errors.first.attribute).to eq(:assignee)
    end

    it 'must create ticket with default draft status' do
    
      user = create(:user)

      ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        due_date: Date.tomorrow,
        assignee: user
      )

      expect(ticket.id).not_to be_nil
      expect(ticket.errors).to be_empty
      expect(ticket.status.name).to eq(TicketStatus::STATUSES[:draft])
    end
  end
end
