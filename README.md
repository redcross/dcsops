# ARCData [![Build Status](https://travis-ci.org/redcross/arcdata.svg?branch=master)](https://travis-ci.org/redcross/arcdata) [![Coverage Status](https://coveralls.io/repos/github/redcross/arcdata/badge.svg?branch=master)](https://coveralls.io/github/redcross/arcdata?branch=master)

ARCData is a tool for managing some Red Cross Disaster Services processes, such as managing DAT shifts.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See "Deployment" for notes on how to deploy the project to staging or production environments.

### Prerequisites

You'll need the following on your system to get started:

- Ruby

  You'll need a working Ruby installation. The project expects Ruby 2.1.2. [rvm](https://rvm.io) or a similar tool is recommended for managing Ruby installations and gemsets.

- Postgres

  This project uses [PostgreSQL](https://www.postgresql.org/download/) as its database. If you're on macOS and you have [Homebrew](https://brew.sh) installed (recommended), then you can just do:

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

### Setup

If you have all the prerequisites above, setting up the project is as simple as running `rake bootstrap`. This does several things to get you set up for development:

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

In production, this project uses Red Cross SSO for authentication. If you want to sign in using the test user, you'll need to use the following URL:

[http://localhost:3000/roster/session/new?legacy=true](http://localhost:3000/roster/session/new?legacy=true)

That will get you the traditional username/password auth, where you can use the test user credentials set up by the bootstrap script.

## Running the test suite

Pretty simple:

```bash
$ rake
```

## Deployment

This project is deployed on Heroku. You'll need a Heroku account and collaborator access granted to do anything with the production instance.

Once you've got that, you'll probably want the [Heroku command line tools](https://devcenter.heroku.com/articles/heroku-cli#download-and-install) installed:

```bash
$ brew install heroku/brew/heroku
```

To interact with the app from the command line, set up git remote to it:

```bash
$ heroku git:remote --app arcdata
```

Then you can push to it. Database migrations are not run automatically, so don't forget to run those after deploy if you need to:

```bash
$ git push heroku master
$ heroku run rake db:migrate
```

## Contributing

[TODO](https://github.com/blog/1184-contributing-guidelines). Link to `CONTRIBUTING.md`.

## License

This project is licensed under the AGPL-3.0 License. See the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- TODO...
- Hat tip to folks who helped
- Inspirations
- Etc.
