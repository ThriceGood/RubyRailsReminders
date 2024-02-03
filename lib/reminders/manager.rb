module Reminders
  class Manager

    # to extend with extra reminder types (push notifications for example)
    # implement a new class that inheirits from Reminders::Base
    # add the lowercase name of the class to the REMINDER_TYPES constant
    # then when a user has this reminder type added to their configured_reminder_types field
    # it will be used to send them reminders of this type when they are scheduled
    
    REMINDER_TYPES = %w[email]
  
    def self.send_reminders
      User.with_active_reminder_tickets.each do |user|
        user.tickets.each do |ticket|
          self.send_reminder_at_intervals(user, ticket)
        end
      end
    end

    def self.send_reminder_at_intervals(user, ticket)
      interval = user.due_date_reminder_interval
      start_date = Date.current
      end_date = ticket.due_date

      (start_date..end_date).step(interval) do |send_date|
        send_time = Time.parse("#{send_date} #{user.due_date_reminder_time}")
        self.send_reminder(user, ticket, send_time)
      end
    end
  
    def self.send_reminder(user, ticket, send_time)
      user.configured_reminder_types.each do |reminder_type|
        self.reminder_of_type(reminder_type).send(ticket, send_time)
      end
    end
  
    def self.reminder_of_type(reminder_type)
      raise ArgumentError, "Invalid reminder type: #{reminder_type}" unless REMINDER_TYPES.include?(reminder_type)
  
      "Reminders::#{reminder_type.capitalize}".constantize
    end

    private_class_method :send_reminder_at_intervals
    private_class_method :send_reminder
    private_class_method :reminder_of_type
  end
end
