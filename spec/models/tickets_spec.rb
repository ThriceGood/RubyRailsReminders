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

  describe 'ticket reminders' do

    before(:each) do
      user = create(
        :user,
        due_date_reminder_day_offset: 1,
        due_date_reminder_interval: 1,
        due_date_reminder_time: '09:00',
        time_zone: 'Europe/Vienna'
      )
      
      @ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        due_date: Date.today + 2.days,
        assignee: user
      )

      @first_reminder_time = Time.parse("#{Date.current + 1.day} #{user.due_date_reminder_time} #{user.time_zone}")
      @second_reminder_time = @first_reminder_time + 1.day
    end

    it 'must create reminders for assignee on create' do
      expect(@ticket.reminders.count).to eq(2)
      expect(@ticket.reminders.first.run_at).to eq(@first_reminder_time)
      expect(@ticket.reminders.second.run_at).to eq(@second_reminder_time)
    end

    it 'must destroy existing reminders and regenerate reminders when assignee changed' do
    
      user = create(
        :user,
        due_date_reminder_day_offset: 1,
        due_date_reminder_interval: 1,
        due_date_reminder_time: '11:00',
        time_zone: 'Europe/Moscow'
      )

      @ticket.assignee = user
      @ticket.save
    
      first_reminder_time = Time.parse("#{Date.current + 1.day} #{user.due_date_reminder_time} #{user.time_zone}")
      second_reminder_time = first_reminder_time + 1.day

      expect(@ticket.reminders.count).to eq(2)
      expect(@ticket.reminders.first.run_at).to eq(@first_reminder_time)
      expect(@ticket.reminders.second.run_at).to eq(@second_reminder_time)
    end

    it 'must not create reminders in the past' do

      @ticket.update(due_date: Date.today - 1.day)

      user = create(
        :user,
        due_date_reminder_day_offset: 1,
        due_date_reminder_interval: 1,
        due_date_reminder_time: '11:00',
        time_zone: 'Europe/Moscow'
      )

      @ticket.assignee = user
      @ticket.save

      expect(@ticket.reminders).to be_empty
    end

  end
end
