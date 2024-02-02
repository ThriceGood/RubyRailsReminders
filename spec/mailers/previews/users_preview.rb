# Preview all emails at http://localhost:3000/rails/mailers/users
class UsersPreview < ActionMailer::Preview
  def reminder_mail
    ticket = FactoryBot.build(:ticket)
    UsersMailer.reminder_mail(ticket)
  end
end
