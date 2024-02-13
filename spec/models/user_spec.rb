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

    it 'must not create user if reminder settings are missing when send_due_date_reminder is true' do 
    
      user = User.create(name: 'Josh Smith', email: 'mail@mail.com', send_due_date_reminder: true)

      errors = {:due_date_reminder_day_offset=>["can't be blank"],
                :due_date_reminder_interval=>["can't be blank"],
                :due_date_reminder_time=>["can't be blank"],
                :time_zone=>["can't be blank"]}
    
      expect(user.errors).not_to be_empty
      expect(user.errors.messages).to eq(errors)
    end
  end

  describe "user's reminders" do
  
    it 'must create reminders for user when setting send_due_date_reminder from false to true' do

      user = create(:user, send_due_date_reminder: false)
      ticket = create(:ticket, assignee: user)

      user.update(send_due_date_reminder: true)

      expect(ticket.reminders.count).to eq(2)
    end

    it 'must destroy reminders for user when setting send_due_date_reminder from true to false' do

      ticket = create(:ticket)
      ticket.regenerate_reminders

      expect(ticket.reminders.count).to eq(2)

      ticket.assignee.update(send_due_date_reminder: false)

      ticket.reload

      expect(ticket.reminders).to be_empty
    end

    it 'must regenerate reminders after changing reminder settings' do
    
      user = create(
        :user,
        due_date_reminder_day_offset: 1,
        due_date_reminder_interval: 1,
        due_date_reminder_time: '09:00',
        time_zone: 'Europe/Vienna'
      )
      
      ticket = Ticket.create(
        title: 'A ticket', 
        description: 'A ticket', 
        due_date: Date.today + 2.days,
        assignee: user
      )

      # reminder times based on original settings
      first_reminder_time = Time.parse("#{Date.current + 1.day} #{user.due_date_reminder_time} #{user.time_zone}")
      second_reminder_time = first_reminder_time + 1.day

      expect(ticket.reminders.count).to eq(2)
      expect(ticket.reminders.first.run_at).to eq(first_reminder_time)
      expect(ticket.reminders.second.run_at).to eq(second_reminder_time)

      user.update(due_date_reminder_time: '10:00')

      # reminder times based on updated settings
      new_first_reminder_time = Time.parse("#{Date.current + 1.day} #{user.due_date_reminder_time} #{user.time_zone}")
      new_second_reminder_time = new_first_reminder_time + 1.day
      
      ticket.reload

      expect(ticket.reminders.count).to eq(2)
      expect(ticket.reminders.first.run_at).to eq(new_first_reminder_time)
      expect(ticket.reminders.second.run_at).to eq(new_second_reminder_time)
    end 
  
  end
end
