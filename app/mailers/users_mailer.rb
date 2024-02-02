class UsersMailer < ApplicationMailer
  def reminder_mail(ticket)
    @ticket = ticket
    
    mail(
      to: ticket.assignee.email, 
      subject: "Reminder: Due date for \"#{ticket.title}\" is upcoming"
    )
  end
end
