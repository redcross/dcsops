# Installing arcdata

1. Get the code.

        $ git clone https://github.com/redcross/arcdata.git
        $ cd arcdata

2. Install Ruby


3. Switch Ruby version to 2.1.2
   
    Bundle install to install/update at gems
      
        $ bundle install  

    * If you get an error: An error occurred while installing capybara-webkit (1.3.0), and Bundler cannot continue, then (assuming you have homebrew on your computer):

        `$ brew install qt`


4.  Go to config
    
    - Copy the content in database.tmpl.yml
    - Create a new file, database.yml
    - Paste the content into database.yml


5.  We will encounter many errors due to the private and public keys when we migrate. So first will temporarily comment out out those line

     ` ERROR: No such file or directory @ rb_sysopen -arcdata/local/id_token/private.key `

    Go to `arcdata/config/initializers/connect.rb and comment out lines 29-32`

          # self.jwt_issuer = Rails.env.development?           ? "https://localhost"             : ENV['OPENID_ISSUER']
          # self.private_key = Rails.env.development?          ? File.read(root + "private.key") : ENV['OPENID_KEY']
          # self.private_key_password = Rails.env.development? ? "pass-phrase"                   : ENV['OPENID_PASSPHRASE']
          # self.certificate = Rails.env.development? 


          ERROR: NoMethodError: undefined method `encrypt_with_public_key' for #<Class:0x007f81dd2aa0b0>


    Go into `a/db/migrate/20140122192338_add_cac_encryption.rb` and comment out the line 5

          # encrypt_with_public_key :encrypted_cac, public_key: ENV['CAC_PUBLIC_KEY'], private_key: ENV['CAC_PRIVATE_KEY'], symmetric: :never



6.  Create & migrate database

        $ rake db:create & rake db:migrate



7.  Update db/seeds.rb with your test data especially with your username and password. Then seed data.

        $ rake db:seed
    


8.  Start the Arcdata app

    For development, you can just do this:

        $ be rails serve      or        be rails s






