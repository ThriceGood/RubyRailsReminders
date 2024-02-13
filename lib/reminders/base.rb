module Reminders
  class Base
    def self.schedule(_ticket, _send_time)
      raise NotImplementedError, "#{self} must implement the 'schedule' method and return a Delayed::Job instance"
    end
  end
end