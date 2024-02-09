module Reminders
  class Manager

    # to extend with extra reminder types (push notifications for example)
    # implement a new class that inheirits from Reminders::Base
    # the class must implement the 'schedule' function and return a Delayed::Job instance
    # add the lowercase name of the class to the REMINDER_TYPES constant
    # then when a user has this reminder type added to their configured_reminder_types field
    # it will be used to send them reminders of this type when they are scheduled
    
    REMINDER_TYPES = %w[email]

    def self.create_reminders_for(ticket)
      assignee = ticket.assignee
      day_offset = assignee.due_date_reminder_day_offset.days
      first_reminder_date = (ticket.due_date - day_offset).to_date

      reminder_intervals = (first_reminder_date..ticket.due_date).step(assignee.due_date_reminder_interval)
      reminder_jobs = []

      reminder_intervals.each do |send_date|
        Time.use_zone(assignee.time_zone) do 
          send_time = Time.zone.parse("#{send_date} #{assignee.due_date_reminder_time}")
          next if send_time < Time.current

          assignee.configured_reminder_types.each do |reminder_type|
            reminder_jobs << self.reminder_of_type(reminder_type).schedule(ticket, send_time)
          end
        end
      end

      reminder_jobs
    end

    def self.reminder_of_type(reminder_type)
      raise ArgumentError, "Invalid reminder type: #{reminder_type}" unless REMINDER_TYPES.include?(reminder_type)
  
      "Reminders::#{reminder_type.capitalize}".constantize
    end

    private_class_method :reminder_of_type
  end
end
