# Installing arcdata

1. Get the code.

        $ git clone https://github.com/redcross/arcdata.git
        $ cd arcdata

2. You'll need to install Ruby inside rbenv.  This assumes that you have
   both Ruby and rbenv installed.

    $ rbenv install 2.1.2

   If you get an error here about OpenSSL, see
   [here](https://github.com/rbenv/ruby-build/issues/834) for more
   information and to find out whether this fix is appropriate.  Try:

    $ curl -fsSL https://gist.github.com/mislav/055441129184a1512bb5.txt | rbenv install --patch 2.1.2

3. Open seeds.rb and edit the username and password in the last code
   block of that file.  The last few lines of seeds.rb create an example
   / test user.  You're welcome to use those creds locally, but will
   definitely want to change them for any production use.  Be sure not
   to store real creds in seeds.rb!

4. Run `./bin/setup` in the project directory

   If you see an error about `capybara-webkit`, check your version of
   `qmake`.  You may want to follow the suggestion
   [here](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)
   to run this on Debian:

        $ sudo apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

   Or this on a Mac:

        $ brew install qt

   ...in order to update qmake and install capybara-webkit
   successfully.


5. The setup script should create your db, but if it fails for
   permission reasons, try the following, with your system username in
   place of `myuser`:

   ```
   $ su - postgres  
   $ psql  
   postgres=# CREATE DATABASE "arcdata-dev";

   # if your user is not already a postgres user:
   postgres=# CREATE USER myuser WITH SUPERUSER;
   
   # otherwise, if your user is already a postgres user:
   postgres=# ALTER USER myuser WITH SUPERUSER;

   # either way, continue with:
   postgres=# GRANT ALL ON DATABASE "arcdata-dev" TO myuser;  
   postgres=# \q  
   ```

6. Run `./bin/setup` again.  Once it runs without errors, your app is set up.

7. Run `bundle exec unicorn -c unicorn.rb` to start the development
   server and visit [http://0.0.0.0:8080](http://0.0.0.0:8080) in your
   browser.  Login with the credentials you created in seeds.rb.  The
   defaults are `admin` and `test123`.

