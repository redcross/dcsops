require 'spec_helper'

describe "root/index.html.haml" do
  let(:person) {FactoryGirl.create :person, last_name: 'Laxson'}

  before do
    view.stub :homepage_links => {}
    view.stub :current_user => person
    view.stub :current_chapter => person.chapter
  end

  it "should render" do
    render
  end

  it "should render homepage links" do
    link = FactoryGirl.create :homepage_link
    links = {link.group => [link]}
    view.stub :homepage_links => links
    render
    rendered.should match(link.group)
    rendered.should match(link.name)
    rendered.should match(link.icon)
    rendered.should match(link.url)
  end
end
