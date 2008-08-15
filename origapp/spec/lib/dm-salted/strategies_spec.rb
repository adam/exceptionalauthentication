require File.join(File.dirname(__FILE__), "..", "..", 'spec_helper.rb')
require 'base64'

describe "Salted DM user" do
  before(:all) do
    Authentication.login_strategies.clear!
    load File.dirname(__FILE__) / "../../../lib/plugins/dm-salted/strategies.rb"
  end
  
  before(:each) do  
    @user = User.create(:login => "fred", :email => "fred@example.com", :password => "tester", :password_confirmation => "tester")
    @user.stub!(:active?).and_return(true)
  end

  after(:each) do
    @user.destroy
  end

  it "should authenticate the user" do
    User.authenticate("fred", "tester").should == @user
  end

  it "should raise an error when the user does not exist" do
    User.should_receive(:first).and_return(nil)
    lambda do
      dispatch_to(Sessions, :update, :login => "foo", :password => "fake")
    end.should raise_error(Merb::Controller::Unauthenticated)
  end

  it "should try to find a user with login and password" do
    User.should_receive(:authenticate).with("fred", "tester").and_return(@user)
    lambda do
      dispatch_to(Sessions, :update, :login => "fred", :password => "tester")
    end.should_not raise_error(Merb::Controller::Unauthenticated)
  end

  it "should check that the user is active" do
    User.should_receive(:first).and_return(@user)
    @user.should_receive(:active?).and_return(true)
    dispatch_to Sessions, :update,  :login => "fred", :password => "tester"
  end

  it "should raise an error if the user is not active" do
    User.should_receive(:first).and_return(@user)
    @user.should_receive(:active?).and_return(false)
    lambda do
      dispatch_to Sessions, :update, :login => "fred", :password => "tester"
    end.should raise_error(Merb::Controller::Unauthenticated)
  end

  it "should login with basic authentication" do
    User.stub!(:authenticate).and_return(nil)
    User.should_receive(:authenticate).with("fred", "tester").and_return(@user)
    lambda do
      dispatch_with_basic_authentication_to(Sessions, :update, "fred", "tester") 
    end.should_not raise_error
  end
end