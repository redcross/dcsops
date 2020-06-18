require 'spec_helper'

describe "System Jobs Admin Page", :type => :feature do
  before(:each) do
    grant_role! :chapter_config
  end

  # Jobs actually get created by enqueing a job, not
  # through the admin interface
  it "Creates a new Job" do
    MyJob = Struct.new(:noop) do
      def perform
        error "Failing job"
      end
    end

    # This is usually set to false because we're in test, so we need
    # to make sure it's true so we see the job show up in the table
    Delayed::Worker.delay_jobs = true
    Delayed::Job.enqueue MyJob.new

    visit "/scheduler_admin/jobs"

    page.should have_text "MyJob"

    click_on "View"

    Delayed::Job.destroy_all
    Delayed::Worker.delay_jobs = false
  end
end
