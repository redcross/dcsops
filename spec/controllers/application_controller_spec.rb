require 'spec_helper'

describe ApplicationController do
  include LoggedIn

  describe "Impersonation" do

    let(:impersonated) { FactoryGirl.create(:person, chapter: @person.chapter) }

    it "should give the current user when asked" do
      controller.current_user.should == @person
    end

    it "should give the current user when impersonating and not authorized" do
      session[:impersonating_user_id] = impersonated.id

      controller.impersonating_user.should be_nil
      controller.current_user.should == @person
    end

    it "should give the impersonated user when impersonating and authorized" do
      session[:impersonating_user_id] = impersonated.id
      controller.stub can_impersonate: true

      controller.impersonating_user.should == impersonated
      controller.current_user.should == impersonated
    end

    it "should check that the logged in user is authorized to impersonate" do
      AdminAbility.any_instance.should_receive(:can?).with(:impersonate, anything).and_return(false)

      controller.can_impersonate(impersonated).should be_false
    end


  end

end