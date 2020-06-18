require 'spec_helper'

describe "root/index.html.haml", :type => :view do
  let(:person) {FactoryGirl.create :person, last_name: 'Laxson'}

  before do
    view.stub :homepage_links => {}
    view.stub :current_user => person
    view.stub :current_region => person.region
  end

  it "should render" do
    render
  end

  it "should render homepage links" do
    link = FactoryGirl.create :homepage_link
    links = {link.group => [link]}
    view.stub :homepage_links => links
    render
    expect(rendered).to match(link.group)
    expect(rendered).to match(link.name)
    expect(rendered).to match(link.icon)
    expect(rendered).to match(link.url)
  end
end
