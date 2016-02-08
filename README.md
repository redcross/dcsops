# ARCData

ARCData is a tool for managing some Red Cross Disaster Services processes, such as managing DAT shifts.

## Setup

ARCData is a Ruby on Rails app and depends on:

- [PostgreSQL XX](http://www.postgresql.org/download/)
- [Ruby 2.1.2](http://www.ruby-lang.org/en/downloads/)

ARCData expects to be able to connect to postgres using your user account without a password.

Once you have Ruby and PostgreSQL installed, run `./bin/setup` in the project directory.

You may get errors during setup if the dependencies of the dependencies aren't installed. The best way to resolve these issues is to search for the issue you're encountering for your operating system and repeat.

See [INSTALL.md](INSTALL.md) for more detailed instructions.
