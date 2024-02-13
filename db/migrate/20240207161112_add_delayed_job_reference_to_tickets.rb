class AddDelayedJobReferenceToTickets < ActiveRecord::Migration[7.1]
  def change
    add_reference :delayed_jobs, :ticket, foreign_key: true
  end
end
