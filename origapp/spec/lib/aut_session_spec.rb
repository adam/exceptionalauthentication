require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Authentication::Session do

  before(:all) do
    Merb::CookieSession.send(:include, Authentication::Session)
  end
  
  before(:each) do
    @session = Merb::CookieSession.new( "", "sekrit")
  end

  describe "module methods" do
    before(:each) do
      Authentication.reset_strategies_to_default!
    end
    
    after(:all) do
      Authentication.reset_strategies_to_default!
    end
    
    describe "reset_strategies_to_default!" do
      it "should reset to the :salted_login strategy" do
        Authentication.reset_strategies_to_default!
        Authentication.active_login_strategies.to_a.should == [:salted_login]
        Authentication.login_strategies[:salted_login].should be_a_kind_of(Proc)
      end
      
      it "should reset after adding another strategy" do
        Authentication.add_login_strategy(:another_one){ "stuff" }
        Authentication.active_login_strategies.should include(:another_one)
        Authentication.login_strategies.keys.should include(:another_one)
        Authentication.reset_strategies_to_default!
        Authentication.active_login_strategies.should_not include(:another_one)
        Authentication.login_strategies.keys.should_not include(:another_one)
        Authentication.active_login_strategies.should include(:salted_login)
      end
    end
    
    describe "add_login_strategy" do
      it "should add a finder strategy" do
        Authentication.add_login_strategy(:a_different_one) do 
          user = User.first(:login => params[:login])
          if user && user.crypted_password == User.encrypt(user.salt, params[:password])
            user
          else
            nil
          end
        end
        Authentication.login_strategies[:a_different_one].should be_a_kind_of(Proc)
        Authentication.active_login_strategies.map{|s| s}.should == [:salted_login, :a_different_one]
      end
    end
    
    describe "active_login_strategies=" do
      before(:each) do
        @set = [:salted_login]
      end
      
      it "should accept an item if it responds to each" do
        @set.stub!(:respond_to?).with(:each).and_return(true)
        Authentication.active_login_strategies = @set
        Authentication.active_login_strategies.should == @set
      end
      
      it "should not accept an item if it does not respond to each" do
        @set.stub!(:respond_to?).with(:each).and_return(false)
        lambda do
          Authentication.active_login_strategies = @set
        end.should raise_error
      end
      
      it "should not accept an item if it is empty?" do
        lambda do
          Authentication.active_login_strategies = []
        end.should raise_error
      end
      
      it "should not accept the set if it contains an item not registered" do
        Authentication.login_strategies.keys.should_not include(:not_here)
        lambda do
          Authentication.active_login_strategies = [:salted_login, :not_here]
        end.should raise_error
      end
      
      it "should recieve the set if it contains only registered items" do
        Authentication.login_strategies.keys.should include(:salted_login)
        lambda do
          Authentication.active_login_strategies = [:salted_login]
        end.should_not raise_error
      end      
    end
    
    describe "remove_login_strategy!" do
      before(:each) do
        Authentication.reset_strategies_to_default!
        Authentication.add_login_strategy(:test_login){"stuff"}
      end
      
      after(:all) do
        Authentication.reset_strategies_to_default!
      end
      
      it "should remove a strategy" do
        Authentication.login_strategies.keys.should include(:test_login)
        Authentication.active_login_strategies.should include(:test_login)
        Authentication.remove_login_strategy!(:test_login)
        Authentication.login_strategies.keys.should_not include(:test_login)
        Authentication.active_login_strategies.should_not include(:test_login)
      end
      
      it "should be able to remove the defualt strategies" do
        Authentication.login_strategies.keys.should include(:salted_login)
        Authentication.active_login_strategies.should include(:salted_login)
        Authentication.remove_login_strategy!(:salted_login)
        Authentication.login_strategies.keys.should_not include(:salted_login)
        Authentication.active_login_strategies.should_not include(:salted_login)
      end
    end
    
      
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
  
  describe "authenticate" do
    before(:each) do
      @controller = Application.new(Merb::Request.new({}))
      @controller.setup_session
      @controller.params[:login] = "fred"
      @controller.params[:password] = "sekrit"
      @strategies = [:salted_login]
      Authentication.stub!(:active_login_strategies).and_return(@strategies)
    end
    
    it "should detect the first user that is not nil" do
      @strategies.should_receive(:detect)
      @controller.session.authenticate(@controller)
    end
    
    it "should execute it in the controller context" do
      block = Authentication.login_strategies[:salted_login]
      @controller.should_receive(:instance_eval)
      @controller.should_receive(:params).any_number_of_times.and_return({:login => "fred", :password => "sekrit"})
      @controller.session.authenticate(@controller)
    end
    
    it "shoudl not authenticate for a user that does not exist" do
      User.first(:login => "fred").should be_nil
      @controller.session.authenticate(@controller).should be_nil
    end
    
  end

end