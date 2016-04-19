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

3. (Optional) Open seeds.rb and edit the username and password in the last code
   block of that file.  The last few lines of seeds.rb create an example
   / test user.  You're welcome to use those creds locally, but will
   definitely want to change them for any production use.  Be sure not
   to store real creds in seeds.rb!

        Note: If you do not change your username and password, see below
        Default username: admin
        Default password: test123

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
6. Try ./bin/setup again.  If you get an error like:

    ```
    ActiveRecord::UnknownAttributeError: unknown attribute: password
    /home/cdonnelly/Documents/arcdata/db/seeds.rb:166:in `<top (required)>'
    -e:1:in `<main>'
    NoMethodError: undefined method `password=' for #<Roster::Person:0x00559a076ac498>
    /home/cdonnelly/Documents/arcdata/db/seeds.rb:166:in `<top (required)>'
    -e:1:in `<main>'
    ```

    then do the following workaround, as outlined in issue #91:

    ```
    $ git checkout ec88f9307dbcbb6eec33d0307773df5372bb62f5
    $ ./bin/setup
    $ git checkout dev-setup
    $ ./bin/setup
    ```
    
7. Run `./bin/setup` again.  Once it runs without errors, your app is set up.

8. Run `bundle exec unicorn -c unicorn.rb` to start the development
   server and visit [http://0.0.0.0:8080](http://0.0.0.0:8080) in your
   browser.  Login with the credentials you created in seeds.rb.  The
   defaults are `admin` and `test123`.


### Note: These next steps are necessary to test getting messages from Twilio to your application and to your phone.

## Appendix A: Getting a trial Twilio account

Some
[issues](https://github.com/redcross/arcdata/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+sms)
are about SMS notifications, so may involve sending sample texts through
Twilio as part of testing.

1. Go to [Twilio](https://www.twilio.com/try-twilio) to sign up for a trial
account and verify your phone number.  With a trial account, you'll only
be able to text yourself.

2. Retrieve your Twilio SID and Token

   a. Click on your email to the top bar to the right

   b. In the drop down, click Account
   
   c. Copy Twilio Account SID & Token 

3. Assign Twilio to Chapter 
        
        $ rails c
        $ chapter = Roster::Chapter.first // OR THE CHAPTER YOUR APP WILL BE RUNNING THE LOCAL INSTANCE ON
        $ chapter.twilio_account_sid = [INSERT TWILIO ACCOUNT SID]
        $ chapter.twilio_auth_token = [INSERT TWILIO AUTH TOKEN]
        Note: Remove brackets when inserting the account sid and token
        $ chapter.save

4. Create a Twilio Phone Number 

5. Assign your Twilio number to chapter
        
        $ chapter.incidents_twilio_number = [TWILIO PHONE NUMBER]
        NOTE: The Twilio Phone number must be formatted with a +1 as that is the way Twilio will send it to the server
        Example: +12143126493 (NO DASHES)
        $ chapter.save

## Appendix B Get a local instance accessible to Twilio 
#### Note: If you already have your local instance hosted publicly (e.g. on Heroku) you can skip to the next appendix 

In order to receive inbound messages from Twilio, Twilio recommends setting up ngrok to make localhost accessible via Twilio. 

See this url: https://www.twilio.com/blog/2013/10/test-your-webhooks-locally-with-ngrok.html 

1. Download ngrok to your computer
2. In terminal, navigate to folder where ngrok is installed
2. Run ngrok to point your server
        $ ngrok http 8080
3. Copy the forwarding address given to you by ngrok after typing the above prompt. Place this in the browser and test to see that it points to the application. 
4. Keep note of the forwarding address/base url to be used for setting up the messaging service.

## Appendix C Create a Messaging Service
1. In Twilio, click Products on the top and in Drop down, select 'Phone Numbers'
3. Under Manage Numbers, select the phone number you will be using for application.
   You will be redirected to a page to manage phone number
4. Under Messaging, select 'Create a New Messaging Service' and follow the routes to create a service.
5. Under inbound settings, in Request URL, place your complete forwarding address. 
6. Your complete forwarding address is {BASE_URL}/incidents/api/twilio_incoming
   

   Example: http://dbff6aa5.ngrok.io/incidents/api/twilio_incoming.
   See above on creating a local instance available for Twilio

## Appendix B -- Set up a Responder Account
1. Run rails c in project directory and assign your number to admin or any other responder account

        $ rails c
        $ responder = Roster::Person.find_by_last_name 'Admin_User'
        $ responder.sms_phone = [YOUR NUMBER]
        NOTE: Do not include country code such as +1
        Example: 123456789 (NO DASHES)
        $ responder.save

2. Still in rails c, assign your cell carrier.
        To see all the list of carriers already in the database, run:
        
        $ Roster::CellCarrier.all
   
  List of all carriers already installed:
  
  * Alltel
  * AT&T
  * Boost Mobile
  * Sprint
  * T-Mobile
  * US Cellular
  * Verizon
  * Virgin Mobile
  
  Get your carrier:
        
        $ carrier = Roster::CellCarrier.find_by_name([NAME OF CARRIER])
        Example:
        $ carrier = Roster::CellCarrier.find_by_name("AT&T")

  If your carrier is not in the list, do this:
        
        $ carrier = Roster::CellCarrier.create(:name => [NAME OF CARRIER], :sms_gateway => [SMS GATEWAY FOR CARRIER])
        Example:
        $ carrier = Roster::CellCarrier.create(:name => 'Verizon', :sms_gateway => '@vtext.com')

  Now associate the carrier to  your account (perhaps admin) like this:
        
        $ responder.sms_phone_carrier = carrier
        $ responder.save



Now you should be ready to send messages from your app to a responder and back
