require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Authentication::Session do

  before(:all) do
    Merb::CookieSession.send(:include, Authentication::Session)
  end
  
  before(:each) do
    @session = Merb::CookieSession.new( "", "sekrit")
  end

  def clear_strategies
    Authentication.login_strategies(:pre_find).clear!
    Authentication.login_strategies(:find).clear!
    Authentication.login_strategies(:post_find).clear!
  end

  describe "module methods" do
    before(:each) do
      @m = mock("mock")
      clear_strategies
    end
    
    after(:all) do
      clear_strategies
    end
    
    describe "login_strategies" do
      it "should provide access to these strategies" do
        [:pre_find, :find, :post_find].each do |s|
          Authentication.login_strategies(s).should be_a_kind_of(Authentication::StrategyContainer)
        end
      end
    
      it "should allow adding a pre_find strategy" do
        Authentication.login_strategies(:pre_find).add(:attempted_login){@m.attempted_login}
        @m.should_receive(:attempted_login)
        Authentication.login_strategies(:pre_find)[:attempted_login].call
      end
    
      it "should allow adding a find strategy" do
        Authentication.login_strategies(:find).add(:salted_login){ @m.salted_login }
        @m.should_receive(:salted_login)
        Authentication.login_strategies(:find)[:salted_login].call      
      end
    
      it "should allow adding a post_find strategy" do
        Authentication.login_strategies(:post_find).add(:active_user){ @m.active_user }
        @m.should_receive(:active_user)
        Authentication.login_strategies(:post_find)[:active_user].call
      end
    end # login_strategies
    
    describe "store_user" do
      it{@session.should respond_to(:store_user)}
      
      it "should raise a NotImplemented error by default" do
        lambda do
          @session.store_user("THE USER")
        end.should raise_error(Authentication::NotImplemented)
      end
    end
    
    describe "fetch_user" do
      it{@session.should respond_to(:fetch_user)}
      
      it "should raise a NotImplemented error by defualt" do
        lambda do 
          @session.fetch_user
        end.should raise_error(Authentication::NotImplemented)
      end
    end
  end

  describe "user" do
    it "should call fetch_user with the session contents to load the user" do
      @session[:user] = 42
      @session.should_receive(:fetch_user).with(42)
      @session.user
    end
    
    it "should set the @user instance variable" do
      @session[:user] = 42
      @session.should_receive(:fetch_user).and_return("THE USER")
      @session.user
      @session.assigns(:user).should == "THE USER"
    end
    
    it "should cache the user in an instance variable" do
      @session[:user] = 42
      @session.should_receive(:fetch_user).once.and_return("THE USER")
      @session.user
      @session.assigns(:user).should == "THE USER"
      @session.user
    end
    
    it "should set the ivar to nil if the session is nil" do
      @session[:user] = nil
      @session.user.should be_nil
    end
    
  end
  
  describe "user=" do
    before(:each) do
      @user = mock("user")
      @session.stub!(:fetch_user).and_return(@user)
    end
    
    it "should call store_user on the session to get the value to store in the session" do
      @session.should_receive(:store_user).with(@user)
      @session.user = @user
    end
    
    it "should set the instance variable to nil if the return of store_user is nil" do
      @session.should_receive(:store_user).and_return(nil)
      @session.user = @user
      @session.user.should be_nil
    end
    
    it "should set the instance varaible to nil if the return of store_user is false" do
      @session.should_receive(:store_user).and_return(false)
      @session.user = @user
      @session.user.should be_nil
    end
    
    it "should set the instance variable to the value of user if store_user is not nil or false" do
      @session.should_receive(:store_user).and_return(42)
      @session.user = @user
      @session.user.should == @user
      @session[:user].should == 42
    end
  end
  
  describe "abandon!" do
    
    before(:each) do
      @user = mock("user")
      @session.stub!(:fetch_user).and_return(@user)
      @session.stub!(:store_user).and_return(42)
      @session[:user] = 42
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

  # describe "authenticate" do
  #   before(:each) do
  #     @controller = Application.new(Merb::Request.new({}))
  #     @controller.setup_session
  #     @controller.params[:login] = "fred"
  #     @controller.params[:password] = "sekrit"
  #     Authentication.login_strategies(:find).add(:salted_login)
  #     
  #   end
  #   
  #   it "should detect the first user that is not nil" do
  #     @strategies.should_receive(:detect)
  #     @controller.session.authenticate(@controller)
  #   end
  #   
  #   it "should execute it in the controller context" do
  #     block = Authentication.login_strategies[:salted_login]
  #     @controller.should_receive(:instance_eval)
  #     @controller.should_receive(:params).any_number_of_times.and_return({:login => "fred", :password => "sekrit"})
  #     @controller.session.authenticate(@controller)
  #   end
  #   
  #   it "shoudl not authenticate for a user that does not exist" do
  #     User.first(:login => "fred").should be_nil
  #     @controller.session.authenticate(@controller).should be_nil
  #   end
  #   
  # end

end