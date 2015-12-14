# Installing arcdata

1. Get the code.

        $ git clone https://github.com/redcross/arcdata.git
        $ cd arcdata

2. Install Ruby


3. Switch Ruby version to 2.1.2
   
    Bundle install to install/update at gems
      $ bundle install  

    * If you get an error: An error occurred while installing capybara-webkit (1.3.0), and Bundler cannot continue, then (assuming you have homebrew on your computer):

      $ brew install qt


4.  Go to app/locales
    -Copy the content in database.tmpl.yml
    -Create a new file, database.yml
    -Paste the content into database.yml

5.  We will encounter many errors due to the private and public keys when we migrate. So first will temporarily comment out out those line

      ERROR: No such file or directory @ rb_sysopen -arcdata/local/id_token/private.key 

        Go to arcdata/config/initializers/connect.rb and comment out lines 29-32

          # self.jwt_issuer = Rails.env.development?           ? "https://localhost"             : ENV['OPENID_ISSUER']
          # self.private_key = Rails.env.development?          ? File.read(root + "private.key") : ENV['OPENID_KEY']
          # self.private_key_password = Rails.env.development? ? "pass-phrase"                   : ENV['OPENID_PASSPHRASE']
          # self.certificate = Rails.env.development? 


      ERROR: NoMethodError: undefined method `encrypt_with_public_key' for #<Class:0x007f81dd2aa0b0>

      go into a/db/migrate/20140122192338_add_cac_encryption.rb and comment out the line 5

          # encrypt_with_public_key :encrypted_cac, public_key: ENV['CAC_PUBLIC_KEY'], private_key: ENV['CAC_PRIVATE_KEY'], symmetric: :never



6.  We current dont have any chapters, so to avoid the errors we must comment out a few lines in:

    app/views/root/index.html.haml    -   lines 18-22
          / .row
          /   .app
          /     %a{href: incidents_chapter_root_path(current_chapter)}
          /       %i.fa.fa-fire.fa-2x
          /       %h4 Incidents


    app/views/layouts/application.html.haml   - line 41
          / %li= link_to 'Incidents', incidents_chapter_root_path(current_chapter)


    app/views/scheduler/home/root.html.haml   -   line43-55
          / %tr
          /   %th
          /   - days_of_week.each do |dow|
          /     %th=dow[0..2].titleize
          / - shift_times.each do |time|
          /   %tr
          /     %th
          /       %span{"data-toggle" => 'tooltip', title: flex_time_range(time, current_person.chapter) }
          /         =time.titleize
          /     - days_of_week.each do |dow|
          /       -avail = sched.send("available_#{dow}_#{time}")
          /       %td{class: avail && "avail"}
          /         =avail ? 'Yes' : 'No'    

    app/db/seeds.rb
      -lines 21-26  (grants role column was removed, attribut no longer exists)
      -lines 45-64  


7.  Create a database and a username in postgres
    
    $ be rake db:create

    $ psql arcdata-dev

    $ arcdata-dev=# select * from "roster_people";
    $ arcdata-dev=# \d "roster_people"
    $ arcdata-dev=# insert into "roster_people" ("username") values ('mike');

8.  Create a new user/password in app/db/seeds.rb . Add the following lines below:
    
    me = Roster::Person.find_by_username 'mike'
    me.username = 'mike'
    me.password = 'test'
    me.chapter_id = 1
    me.save!

    Migrate and then seed the data in terminal, 

    $ be rake db:migrate
    $ be rake db:seed

9.  Start the Arcdata app

    For development, you can just do this:

        $ be rails serve      or        be rails s






