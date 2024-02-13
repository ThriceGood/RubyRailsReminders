## Ruby Rails Reminders

A reminders API built using Ruby 3, Rails 7 and PostgreSQL

The API provides access to users and tickets and sends a reminder email to an assigned user about a tickets upcoming due date

### Contents

* [Requirements](#requirements)
* [How to run](#how-to-run)
* [Run the tests](#run-the-tests)
* [Using the API](#using-the-api)
* [Scheduled reminders](#scheduled-reminders)

### Note

For a simpler approach checkout branch `simpler_approach`

### Requirements

* RVM
* Docker 
* Docker Compose

### How to run

Clone and cd into the repository then:

Start the database: `docker compose up -d`

Install Ruby: `rvm install 3.3.0`

Create the gemset: `rvm use ruby-3.3.0@ruby-rails-reminders --create`

Install the dependecies: `bundle install`

Initialize the database: `rails db:prepare`

Start the Delayed Job server (maybe in another terminal window/tab): `rake jobs:work`

Run the rails server: `rails s`

Confirm installation by visiting: [http://localhost:3000/users](http://localhost:3000/users)

You should see something like:

![](images/users_index.png)

You can also visit: [http://localhost:3000/tickets](http://localhost:3000/tickets)

You should see something like:

![](images/tickets_index.png)

## Run the tests

To run the tests run: `rails test` and `rspec`

They should all pass

## Using the API

To CRUD users and tickets follow the standard restful approach using a tool such as Postman

For example, to create a user HTTP `POST` to `/users` with the following JSON body:

```
{
  "name": "Jane Smith",
  "email": "jane@mail.com",
  "send_due_date_reminder": true,
  "due_date_reminder_day_offset": 1,
  "due_date_reminder_time": "09:00:00",
  "due_date_reminder_interval": 1,
  "time_zone": "Europe/Vienna",
  "configured_reminder_types": [
      "email"
  ]
}
```

Afterwards if you HTTP `GET` from `/users` you should see something like:

![](images/new_user.png)

You can also: 

Update a user by using a HTTP `PATCH` with a JSON user object to `/users/1`where `1` is the id of the user

Delete a user by using a HTTP `DELETE` to `/users/1` where `1` is the id of the user

Get a single user by using a HTTP `GET` to `/users/1` where `1` is the id of the user

The same pattern applies to tickets

Here is an example of creating a ticket by using a HTTP `POST` to `/tickets` with a ticket JSON object:

```
{
  "title": "test ticket 2",
  "description": "my ticket 2",
  "assigned_user_id": 1,
  "due_date": "2024-02-03",
  "ticket_status_id": 3
}
```

Afterwards if you HTTP `GET` from `/tickets` you should see something like:

![](images/new_ticket.png)

## Scheduled reminders

When a ticket is created a `before_create` hook will generate and schedule reminders using `Delayed::Job`

There is a model called `Reminder` which is a proxy to the `delayed_jobs` table in the database

The `Ticket` model has a one to many relationship with the `Reminder` model

The `Reminders::Manager` class creates the reminders using the assignee's reminder settings and returns the job instances

The job instances related to the `delayed_jobs` table and the ids from these job instances are stored in `ticket.reminder_ids`

Therefore the reminders (delayed jobs) can be fetched for a ticket using `ticket.reminders`

When a ticket's assignee changes the old reminders (for the old assignee) will be deleted and new reminders will be generated

The user and thier reminder settings look like this:

```
{
  "id": 1,
  "name": "Josh Smith",
  "email": "josh@mail.com",
  "send_due_date_reminder": true,
  "due_date_reminder_day_offset": 2,
  "due_date_reminder_time": "09:00:00",
  "due_date_reminder_interval": 1,
  "time_zone": "Europe/Vienna",
  "configured_reminder_types": [
      "email"
  ]
}
```

When a user sets their `send_due_date_reminder` setting to `false` then all of thier currently scheduled reminders will be deleted

When a user sets their `send_due_date_reminder` setting to `true` then they will have reminders generated for all their assigned tickets

When any other reminder setting (`due_date_*`, `time_zone`) is changed then the reminders will be regenerated based on these new settings 

### Example

If the above user has one ticket with a `due_date` of `2024-06-10` and a `due_date_reminder_day_offset` of `2`

And `due_date_reminder_time` is set to `09:00:00` and the `time_zone` set to `Europe/Vienna`

Then the first reminder is expected on `2024-06-08 09:00:00 +0100`

Because the user has a `due_date_reminder_interval` set to `1` a reminder is expected every day up and including the due date

Therefore the expected reminder times will be:

* `2024-06-08 09:00:00 +0100` (2 days before)
* `2024-06-09 09:00:00 +0100` (1 days before)
* `2024-06-10 09:00:00 +0100` (on due date)

View the RSpec tests to see testing of the above functionality
