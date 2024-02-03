module Reminders
  class Email < Base
    def self.send(ticket, send_time)
      # send instantly in develop
      if Rails.env.development?
        UsersMailer.reminder_mail(ticket).deliver_now
      else
        UsersMailer.delay(run_at: send_time).reminder_mail(ticket)
      end
    end
  end
end