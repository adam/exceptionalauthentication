require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Authentication::Session do

  before(:all) do
    Merb::CookieSession.send(:include, Authentication::Session)
  end
  
  before(:each) do
    @session = Merb::CookieSession.new( "", "sekrit")
  end

  describe "user" do
    it "should return nil if the :user_id is not set" do
      @session[:user_id].should be_nil
      @session.user.should be_nil
    end
    
    it "should look in the database if the user_id is set" do
      @session[:user_id] = 42
      user = mock("user")
      User.should_receive(:get).with(42).and_return(user)
      @session.user.should == user
    end
  end
  
  describe "user=" do
    
    before(:each) do
      @user = User.new
      @user.stub!(:id).and_return(42)
      @user.stub!(:new_record?).and_return(false)
    end
    
    it "should setup the user if the user is a User object" do
      @session.user = @user
      @session.user.should == @user
    end  
    
    it "should setup the :user_id for the user" do
      @session.user = @user
      @session[:user_id].should == 42
    end
    
    it "should abandon the session if the user is nil" do
      @session.should_receive(:abandon!)
      @session.user = nil
    end
    
    it "should abandon the session if the passed in user is not a User" do
      @session.should_receive(:abandon!)
      @session.user = "User"
      @session.user.should be_nil
    end    
  end
  
  describe "abandon!" do
    
    before(:each) do
      @user = mock("user")
      User.stub!(:get).and_return(@user)
      @session[:user_id] = 42
      @session.user
    end
    
    it "should delete the session" do
      @session.should_receive(:delete)
      @session.abandon!
    end
    
    it "should not have a user after it is abandoned" do
      @session.user.should == @user
      @session.abandon!
      @session.user.should be_nil
    end
  end
  
  describe "authenticated?" do

  end

end