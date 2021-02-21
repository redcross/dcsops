# DCSOps Installation and Deployment.

These instructions will get you a copy of DCSOps up and running on your local machine for development and testing purposes.  See the section "Deployment" for notes on how to deploy it to staging or production environments.

## Prerequisites

You'll need the following on your system to get started:

- Ruby

  You'll need a working Ruby installation.  DCSOps expects Ruby 2.2.3. [rvm](https://rvm.io) or a similar tool is recommended for managing Ruby installations and gemsets.

- Postgres

  DCSOps uses [PostgreSQL](https://www.postgresql.org/download/) as its database. If you're on macOS and you have [Homebrew](https://brew.sh) installed (recommended), then you can just do:

  ```bash
  $ brew install postgresql
  ```

- OpenSSL (maybe, for recent versions of macOS)

  Recent versions of macOS remove the system version of OpenSSL, so you may need to install your own copy and point bundler at it:

  ```bash
  $ brew install openssl
  $ cd ~/your/project/directory
  $ bundle config build.eventmachine --with-cppflags=-I$(brew --prefix openssl)/include
  $ bundle config build.puma --with-opt-dir=$(brew --prefix openssl)
  ```

  If you're on macOS and encounter errors while bundle installing puma or eventmachine, you likely need to do the above.

## Setup

If you have all the prerequisites above, setting things up is as simple as running `rake bootstrap`. This does several things to get you set up for development:

  - Ensures bundler is installed
  - Runs bundle install
  - Creates database config from example file if not present
  - Creates database if not present
  - Prompts for approval of potentially destructive actions, then:
    - Loads database schema
    - Loads seed data

```bash
$ rake bootstrap
-----> Checking for bundler... ✔
-----> Installing gems...
Executing: bundle install --without production
[...]
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
-----> Installing example database config...
Executing: cp -n config/database.yml.example config/database.yml
Load database schema and seeds (potentially destructive action)? [yN]  y 
-----> Loading database schema and seeds...
[...]
Seeding finished. Created test user with:
Username: test
Password: password
-----> Finished. Run `rails server` to start the server.
```

Note the required confirmation before loading the database schema and seeds. After that's done you should be able to start the web server and log in with the test user credentials.

```bash
$ rails s
=> Booting Puma
[...]
* Listening on tcp://0.0.0.0:3000
```

In production, DCSOps uses Red Cross SSO for authentication. If you want to sign in using the test user, you'll need to use the following URL:

[http://localhost:3000/roster/session/new?legacy=true](http://localhost:3000/roster/session/new?legacy=true)

That will get you the traditional username/password auth, where you can use the test user credentials set up by the bootstrap script.

## Loading Data from a Backup

To load data from a database dump, run the following commands:

```bash
$ rake db:create
$ pg_restore -d <dbname> <dump_filename>
```

Then, to modify an existing user's login (to test on real data locally), run `rails c` and in the console enter:

```ruby
> test_user = Roster::Person.where("INSERT QUERY")[0]
> test_user.password = "NEW_PASSWORD"
> test_user.save!
```

You should now be able to log in as this modified user at the legacy login URL: [http://localhost:3000/roster/session/new?legacy=true](http://localhost:3000/roster/session/new?legacy=true)

## Running the test suite

Pretty simple:

```bash
$ rake
```

## Deployment

There are two branches for deployment 'production' and 'candidate-production'.  The former is for the arcdata app on heroku, and the latter is for the arcdata-staging app.  Generally, 'production' and 'main' are in step, but there's times when main is more in step with 'candidate-production.'

DCSOps is deployed on Heroku, so you'll need a Heroku account and collaborator access granted to do anything with the production instance.

Once you've got that, you'll probably want the [Heroku command line tools](https://devcenter.heroku.com/articles/heroku-cli#download-and-install) installed:

```bash
$ brew install heroku/brew/heroku
```

To interact with the app from the command line, set up git remote to it:

```bash
$ heroku git:remote --app arcdata # or arcdata-staging for staging
```

At this point, you will want to rename the heroku remote to something more descriptive, so that you can have a staging and production remote in your local git instance.

```bash
$ git remote rename heroku heroku-production
```

Then you can push to it. Database migrations are not run automatically, so don't forget to run those after deploy if you need to:

```bash
$ git push heroku-production production:main
$ # Or git push heroku-staging candidate-production:main
$ heroku run rake db:migrate --app arcadata # Or --app arcdata-staging
```

**IMPORTANT:** Once you have finished a new deployment, please log it in `site-updates.txt`.

## External Services

### Volunteer Connection

[Volunteer Connection](https://volunteerconnection.redcross.org) is the primary source of information on Red Cross volunteers that DATResponse regularly syncs data through Rake tasks on the worker server. The syncing is done partially through web scraping, with most of the scraper code in `lib/vc`. Volunteer Connection credentials are configured on a chapter basis and used to log in, navigate through pages, and either generate content from scraped HTML, JSON, or from an Excel file downloaded in the query tool.

All Volunteer Connection hours are uploaded daily, and other data sources including incidents, users, and user positions are imported hourly through background jobs.

### Periscope

[Periscope](https://www.periscopedata.com/) is an analytics tool used for reporting based on application data.

**IMPORTANT:** Periscope relies on a direct database connection. If the Heroku Postgres credentials are changed, the credentials used in Periscope will need to be changed as well.

### Communication, Messaging

#### Email and Postmark

[Postmark](https://postmarkapp.com) is the application's email service for both outbound and inbound email. The outbound email setup is a standard SMTP configuration. Other than standard emails, it uses cell carrier-specific domains (i.e. vtext.com for Verizon) to send non-urgent SMS texts via email.

##### DirectLine

The inbound mail comes from DirectLine (see below), which sends some incident reports to the application. Inbound emails trigger a webhook to a configurable URL endpoint (currently the `/import` route) which parses the message and imports the contents. Any changes to the site URL or the inbound mail domain forwarding will require updating settings in Postmark.

DirectLine is a call center that three regions use.  They take some basic information and put it into their own proprietary system, and then when they have all the info they send that to DCSOps, which turns it into an incident report for which various people are notified.  The three regions are Cascades (Oregon), Gold Country (Sacramento and Northern CA), and N. CA Coastal (SF and environs).

Each region has a specific email address to which DirectLine pushes incidents; that's how DCSOps knows what region the incident is for.  Those email addresses are in the chapter configuration settings.  (Questions: does DCSOps reconcile that email address with information in the incident, such as zip code?  What if they mutually contradict?  Also, does DirectLine do some validation on their end before sending the incident to DCSOps?)

DirectLine apparently does some dispatch notification on its own.  Every day, DCSOps pushes schedule data to DirectLine so that DirectLine knows who should get notified.

The dispatch logs (available in the admin tool in DCSOps) contain all the information that is pushed to create an incident report, as well as who gets notified, etc.

#### Twilio

[Twilio](https://twilio.com) is used for both sending and receiving SMS messages. Twilio credentials are configured on a per-chapter level, and phone numbers are also configured for each chapter separately.

#### PubNub

[PubNub](https://www.pubnub.com/) allows for real-time updates of information on some of the dispatch and incident pages.

### Monitoring

Several monitoring services are configured through Heroku add-ons, including [Sentry](https://sentry.io) for error reporting, [Papertrail](https://papertrailapp.com/) for storing logs, and [New Relic](https://newrelic.com/) for general application monitoring. Additionally, [UptimeRobot](https://uptimerobot.com/) is used for monitoring outages

### Heroku Scheduler

Scheduler is a cron-like service in Heroku for running commands at regular intervals.

### Google Maps API

The Google Maps API is used for generating driving directions for distance times, geocoding, and any maps that are displayed throughout the application. In particular, it's relevant for creating new incidents, because the application defaults to requiring users to search for an address through Google instead of entering it manually, but this behavior can be turned off on a chapter basis.

### AWS

SQS is used as a queue for the imports from Volunteer Connection, and S3 is used for storing any uploaded files.

## Direct Line

Direct Line is a call center service used by some of the regions in DCSOps. It syncs shift information by sending an email for each region with two CSVs of schedule data attached several times a day.

## Staging Site Setup

We have a staging instance setup at `arcdata-staging` for testing out updates before they're pushed into production. It uses a different database (pulled from production backups), doesn't send emails or text messages, and doesn't contact any external services where changes are made including SQS for the Volunteer Connection import or S3. Delayed job tasks are run every hour until they are completed with `rake jobs:workoff` on a Heroku Scheduler dyno.

In order to update the staging database with a more recent copy of the production database, we have a rake task that downloads a production backup, loads it into a local temporary database, removes unneeded records (to reduce the size of the staging DB), and replaces the Heroku staging database with the modified local data. It can be run with:

```bash
$ rake staging:update_staging_db
```

**Note**: Downloading the production backup and pushing the local data to staging can take some time, but user input is required to confirm the overwriting of the `arcdata-staging` database. This is left in as an extra precaution against accidentally deleting production data.

## Database Management

Heroku Postgres is being used for the PostgreSQL database, so backups and credentials can be managed with the Heroku command line tools. The Heroku Postgres backups are compatible with the Postgres native tools `pg_dump` and `pg_restore`, and you can refer to their [documentation](https://devcenter.heroku.com/articles/heroku-postgres-backups) for more information on creating and managing backups.

We run daily automated backups on Heroku. To schedule automated backups and verify that they are running, you can run the following commands, specifying a 24-hour time and time zone for backups to take be created (with more detail in the [documentation](https://devcenter.heroku.com/articles/heroku-postgres-backups#scheduling-backups)):

```bash
$ heroku pg:backups:schedule DATABASE_URL --at '02:00 America/Chicago' --app arcdata
$ heroku pg:backups --app arcdata
```

To create and then download a backup manually, you'll need to run:

```bash
$ heroku pg:backups:capture --app arcdata
$ heroku pg:backups:download --app arcdata
```

Credentials are also managed through the CLI rather than directly through Postgres itself. You can specify usernames for new database credentials, but passwords are always automatically created by Heroku. Databases running earlier versions of Postgres (~9.3) don't support the [full set of commands and functionality](https://devcenter.heroku.com/articles/heroku-postgresql-credentials), but you can reset the database credentials with:

```bash
$ heroku pg:credentials <DATABASE_NAME> --reset --app arcdata
```
