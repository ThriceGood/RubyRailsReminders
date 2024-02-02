require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe 'user validations' do

    it 'must create user when valid' do
    
      user = User.create(name: 'Josh Smith', email: 'mail@mail.com')

      expect(user.errors).to be_empty
    end

    it 'must not create user without name' do
    
      user = User.create(email: 'test@mail.com')
      
      expect(user.errors).not_to be_empty
      expect(user.errors.first.attribute).to eq(:name)
    end

    it 'must not create user without email' do
    
      user = User.create(name: 'Josh Smith')

      expect(user.errors).not_to be_empty
      expect(user.errors.first.attribute).to eq(:email)
    end

    it 'must not create user without valid email' do
    
      user = User.create(name: 'Josh Smith', email: 'invalid')

      expect(user.errors).not_to be_empty
      expect(user.errors.first.attribute).to eq(:email)
    end

    it 'must create user with valid configured_reminder_types' do
    
      user = User.create(
        name: 'Josh Smith', 
        email: 'mail@mail.com', 
        configured_reminder_types: [Reminders::Manager::REMINDER_TYPES.first]
      )
    
      expect(user.errors).to be_empty
    end

    it 'must not create user with invalid configured_reminder_types' do
    
      user = User.create(name: 'Josh Smith', email: 'mail@mail.com', configured_reminder_types: ['invalid'])
    
      expect(user.errors).not_to be_empty
      expect(user.errors.first.attribute).to eq(:configured_reminder_types)
    end
  end

  describe 'User.with_active_reminder_tickets scope' do

    describe 'users with reminders enabled' do
      
      it 'must return not users if they have no active reminders' do

        create(:ticket)

        users = User.with_active_reminder_tickets

        expect(users).to be_empty
      end
  
      it 'must return users if they have active reminders' do

        ticket = create(:ticket, due_date: Date.tomorrow)
        
        user2 = create(:user, name: 'Joe Smith')
        create(:ticket, assignee: user2, due_date: Date.current + 10.days)
        
        users = User.with_active_reminder_tickets
  
        expect(users).not_to be_empty
        expect(users.count).to eq(1)
        expect(users.first.id).to eq(ticket.assignee.id)
      end
  
      it 'must not return users if the active ticket due_date has passed' do
        
        create(:ticket, due_date: Date.yesterday)

        users = User.with_active_reminder_tickets
  
        expect(users).to be_empty
      end

      it 'must return users with active reminder tickets and without tickets that are passed due_date or not active status' do
        inactive_status = create_ticket_status('inactive')

        # first user
        ticket_active_1 = create(:ticket, due_date: Date.tomorrow) # reminder
        ticket_inactive_1 = create(:ticket, due_date: Date.tomorrow, status: inactive_status)
        ticket_far_future_1 = create(:ticket)
        ticket_past_1 = create(:ticket, due_date: Date.yesterday)

        # second uesr
        ticket_active_2 = create(:ticket, due_date: Date.tomorrow) # reminder
        ticket_inactive_2 = create(:ticket, due_date: Date.tomorrow, status: inactive_status)
        ticket_far_future_2 = create(:ticket)
        ticket_past_2 = create(:ticket, due_date: Date.yesterday)

        users = User.with_active_reminder_tickets

        expect(users).to_not be_empty
        expect(users.count).to eq(2)

        # first user
        expect(users.first.id).to eq(ticket_active_1.assignee.id)
        expect(users.first.tickets.count).to eq(1)
        expect(users.first.tickets.first.id).to eq(ticket_active_1.id)

        # second user
        expect(users.second.id).to eq(ticket_active_2.assignee.id)
        expect(users.second.tickets.count).to eq(1)
        expect(users.second.tickets.first.id).to eq(ticket_active_2.id)
      end
    end

    describe 'users with reminders disabled' do

      it 'must not return users even if within reminder date range' do
      
        user = create(:user, send_due_date_reminder: false)
        create(:ticket, assignee: user, due_date: Date.tomorrow)

        users = User.with_active_reminder_tickets

        expect(users).to be_empty
      end
    end
  end
end
