module Reminders
  class Email < Base
    def self.schedule(ticket, send_time)
      UsersMailer.delay(run_at: send_time).reminder_mail(ticket)
    end
  end
end