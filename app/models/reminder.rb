class Reminder < Delayed::Job
  belongs_to :ticket
end