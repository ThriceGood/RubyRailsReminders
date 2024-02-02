require 'spec_helper'
require 'rails_helper'
require "#{Rails.root}/lib/reminders"


RSpec.describe Reminders::Manager, type: :model do

  describe 'multiple users with a tickets that should and should not be reminded of' do
  
    before(:each) do

      inactive_status = create_ticket_status('inactive')
      due_date = Date.current + 2.day

      # first user
      user1 = create(:user, 
                     due_date_reminder_day_offset: 2, 
                     due_date_reminder_interval: 1,
                     due_date_reminder_time: '08:00:00')

      # remind for these tickets
      @ticket_active_1a = create(:ticket, assignee: user1, due_date: due_date)
      @ticket_active_1b = create(:ticket, assignee: user1, due_date: due_date)

      # current date at user's time
      @ticket_1_send_time = Time.parse(user1.due_date_reminder_time)

      # do not remind for these tickets
      ticket_inactive_1 = create(:ticket, assignee: user1, due_date: due_date, status: inactive_status)
      ticket_far_future_1 = create(:ticket, assignee: user1)
      ticket_past_1 = create(:ticket, assignee: user1, due_date: Date.yesterday)


      # second user
      user2 = create(:user, 
                     due_date_reminder_day_offset: 2,
                     due_date_reminder_interval: 2,
                     due_date_reminder_time: '10:00:00')

      # remind for these tickets
      @ticket_active_2a = create(:ticket, assignee: user2, due_date: due_date)
      @ticket_active_2b = create(:ticket, assignee: user2, due_date: due_date)
      
      # current date at user's time
      @ticket_2_send_time = Time.parse(user2.due_date_reminder_time)

      # do not remind for these tickets
      ticket_inactive_2 = create(:ticket, assignee: user2, due_date: due_date, status: inactive_status)
      ticket_far_future_2 = create(:ticket, assignee: user2)
      ticket_past_2 = create(:ticket, assignee: user2, due_date: Date.yesterday)
    end

    it 'must send email reminder to both users for their reminder tickets only' do

      allow(Reminders::Email).to receive(:send)

      Reminders::Manager.send_reminders
    
      # user1's first remindable ticket will have an email send every day until the ticket due date because
      # he has a reminder interval set to 1 which means he will receive an email every day until the due date
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1a, @ticket_1_send_time)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1a, @ticket_1_send_time + 1.day)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1a, @ticket_1_send_time + 2.days)

      # the same logic applies to his second remindable ticket because it has the same due date
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1b, @ticket_1_send_time)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1b, @ticket_1_send_time + 1.day)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_1b, @ticket_1_send_time + 2.days)

      # the second user has a reminder day offset of 2 and in reminder interval of 2 
      # so he receives a reminder 2 days before and then on the due date per ticket (hence + 2.days)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_2a, @ticket_2_send_time)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_2a, @ticket_2_send_time + 2.days)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_2b, @ticket_2_send_time)
      expect(Reminders::Email).to have_received(:send).with(@ticket_active_2b, @ticket_2_send_time + 2.days)

      # all of the above accounted for, proving no mails sent for non-remindable tickets 
      expect(Reminders::Email).to have_received(:send).exactly(10).times
    end
  end

  describe 'user with 0 offset (remind on due date)' do

    before(:each) do

      user1 = create(:user, 
                     due_date_reminder_day_offset: 0, 
                     due_date_reminder_interval: 1,
                     due_date_reminder_time: '08:00:00')

      @ticket_active = create(:ticket, assignee: user1, due_date: Date.current)
      @send_time = Time.parse(user1.due_date_reminder_time)
    end

    it 'must send email reminder for remindable ticket on ticket due date' do
    
      allow(Reminders::Email).to receive(:send)

      Reminders::Manager.send_reminders

      expect(Reminders::Email).to have_received(:send).with(@ticket_active, @send_time)
    end

  end

  describe 'reminder_of_type method' do
    
    it 'must raise error if called with invalid reminder type' do

      expect { Reminders::Manager.send(:reminder_of_type, 'invalid_type') }.to raise_error(ArgumentError)
    end
  end
end