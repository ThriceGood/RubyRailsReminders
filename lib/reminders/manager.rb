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
      reminder_jobs = []
      assignee = ticket.assignee
      send_times = self.reminder_send_times(ticket)

      send_times.each do |send_time|
        assignee.configured_reminder_types.each do |reminder_type|
          reminder_jobs << self.reminder_of_type(reminder_type).schedule(ticket, send_time)
        end
      end

      reminder_jobs
    end

    private

    def self.reminder_send_times(ticket)
      send_times = []
      assignee = ticket.assignee
      day_offset = assignee.due_date_reminder_day_offset.days
      reminder_time = assignee.due_date_reminder_time
      reminder_interval = assignee.due_date_reminder_interval.days

      send_date = (ticket.due_date - day_offset).to_date

      while send_date <= ticket.due_date
        Time.use_zone(assignee.time_zone) do 
          send_time = Time.zone.parse("#{send_date} #{reminder_time}")
          next if send_time < Time.current

          send_times << send_time
        end
        send_date += reminder_interval
      end

      send_times
    end

    def self.reminder_of_type(reminder_type)
      raise ArgumentError, "Invalid reminder type: #{reminder_type}" unless REMINDER_TYPES.include?(reminder_type)
  
      "Reminders::#{reminder_type.capitalize}".constantize
    end

    private_class_method :reminder_send_times
    private_class_method :reminder_of_type
  end
end
