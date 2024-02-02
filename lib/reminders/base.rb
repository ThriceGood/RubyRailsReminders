module Reminders
  class Base
    def self.send(_ticket, _send_time)
      raise NotImplementedError, "#{self} must implement the 'send' method"
    end
  end
end