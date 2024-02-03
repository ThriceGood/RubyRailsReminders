module Reminders
  class Email < Base
    def self.send(ticket, send_time)
      # UsersMailer.delay(run_at: send_time).reminder_mail(ticket)
      UsersMailer.reminder_mail(ticket).deliver_now
    end
  end
end