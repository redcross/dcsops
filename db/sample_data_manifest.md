I'm trying to run DCSOps and I am receiveing some errors and empty 
content on each page because of the lack of sample data in 
db/migrate/seed.rb. The lists below are all the migrations that were
created.

In the original seed.rb file, there are a few lines that show a local
file being imported to seed the data. Is this the file that contains 
all the sample data that we can possibly seed?


    `#load "lib/vc_importer.rb";`
    `#vc = Roster::VCImporter.new;` 
    `#vc.import_data(Roster::Chapter.first, "/Users/jlaxson/Downloads/LMSync1.xls")`



We have sample data for these migrations:

* Roster People
* Roster Counties
* Roster Positions
* Roster Chapters
* Roster Cell Carries
* Scheduler Shift Groups
* Scheduler Shifts
* Incidents Scopes

We DO NOT have sample data for these migrations:

* Roster County Memberships
* Roster Position Memberships
* Roster Roles
* Roster Role Scopes
* Roster VC Import Data
* Scheduler Shift Allowed Roles
* Scheduler Shift Assignments
* Scheduler Notification Settings
* Scheduler Flex Schedulers
* Scheduler Dispatch Configs
* Scheduler Shift Categories
* Incidents Incidents
* Incidents Cas Incidents
* Incidents Cas Cases
* Incidents Responder Assignments
* Incidents Dat Incidents
* Incidents Deployment
* Incidents Dispatch Logs
* Incidents Dispatch Log Items
* Incidents Event Logs
* Incidents Notification Subsciptions
* Incidents Vehicle Uses
* Incidents Partner Uses
* Incidents Cases
* Incidents Price List Items
* Incidents Case Assistance Items
* Incidents Attachments
* Incidents Disasters
* Incidents Notifications Events
* Incidents Notifications Roles
* Incidents Notifications Triggers
* Incidents Notifications Role Scopes
* Incidents Responder Messages
* Incidents Responder Recruitments
* Incidents Territories
* Incidents Sequence
* Incidents Call Logs
* Incidents Initial Incident Reports
* Logistics Vehicles
* Admin Notes
* Motds
* Partners Partners
* Versions
* Api Clients
* Named Queries
* More Indexes
* Username Index
* Data Filter
* Homepage Links
* Lookups
* Delayed Jobs 

