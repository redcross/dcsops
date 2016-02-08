# ARCData

ARCData is a tool for managing some Red Cross Disaster Services processes, such as managing DAT shifts.

## Setup

ARCData is a Ruby on Rails app and depends on:

- [PostgreSQL XX](http://www.postgresql.org/download/)
- [Ruby 2.1.2](http://www.ruby-lang.org/en/downloads/)

ARCData expects to be able to connect to postgres using your user account without a password.

Once you have Ruby and PostgreSQL installed, run `./bin/setup` in the project directory.

You may get errors during setup if the dependencies of the dependencies aren't installed. The best way to resolve these issues is to search for the issue you're encountering for your operating system and repeat.

## In more detail

1. You'll need to install Ruby inside rbenv.

    $ rbenv install 2.1.2

   If you get an error here about OpenSSL, see
   [here](https://github.com/rbenv/ruby-build/issues/834) for more
   information and to find out whether this fix is appropriate.  Try:

    $ curl -fsSL https://gist.github.com/mislav/055441129184a1512bb5.txt | rbenv install --patch 2.1.2

2. Edit seeds.rb with your username and password.  The last few lines of
   seeds.rb create an example / test user.  You're welcome to use those
   creds locally, but definitely want to change them for any production
   use, and be sure not to store real creds in seeds.rb!

3. Run `./bin/setup` in the project directory

   If you see an error about `capybara-webkit` and you're running
   Debian, check your version of `qmake`.  You may want to follow the
   suggestion
   [here](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)
   to run this:

        $ sudo apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

   ...in order to update qmake and install capybara-webkit
   successfully.


4. The setup script should create your db, but if it fails, try the
   following:

   ```
   $ su - postgres  
   $ psql  
   postgres=# CREATE DATABASE "arcdata-dev";  
   postgres=# ALTER USER myuser WITH SUPERUSER;  
   postgres=# GRANT ALL ON DATABASE "arcdata-dev" TO myuser;  
   postgres=# \q  
   ```

5. Run `./bin/setup` again.  Once it works correctly, your app is set up.

6. Run `bundle exec unicorn -c unicorn.rb` to start the development
   server and visit [http://0.0.0.0:8080](http://0.0.0.0:8080) in your
   browser.  Login with your credentials from seeds.rb.
