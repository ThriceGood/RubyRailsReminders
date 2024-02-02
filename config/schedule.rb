# Use this file to easily define all of your cron jobs.
#
# update crontab with: whenever --update-crontab
# check with: crontab -l

every 1.day, at: '00:00:00 am' do 
  runner "Reminders::Manager.send_reminders", :environment => "development"
end