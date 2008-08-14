require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Exceptions do
  before(:each) do
    @user = mock("user", :null_object => true)
  end
  
  def dispatch(action, options = {}, env = {}, &blk)
    exp = mock("Exception")
    exp.stub!(:message).and_return("you are not logged in")
    options[:exception] ||= exp
    dispatch_to(Exceptions, action, options, env) do |c|
      c.stub!(:params).and_return(options)
      yield if block_given?
    end
  end
  
  describe "unauthenticated" do  
    it "should redirect to :login" do
<<<<<<< HEAD:origapp/spec/controllers/exceptions_spec.rb
      dispatch(
        :unauthenticated, Merb::Controller::Unauthenticated.new('Please Log In')
      ).should redirect_to(url(:login))
=======
      dispatch(:unauthenticated).should redirect
>>>>>>> Adds fetch_user and store_user abstractions:origapp/spec/controllers/exceptions_spec.rb
    end
  end
  
  
end