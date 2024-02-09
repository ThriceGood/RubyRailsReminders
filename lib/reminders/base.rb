module Reminders
  class Base
    def self.schedule(_ticket, _send_time)
      raise NotImplementedError, "#{self} must implement the 'schedule' method"
    end
  end
end