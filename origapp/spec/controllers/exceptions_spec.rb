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
      yield c if block_given?
    end
  end
  
  describe "unauthenticated" do  
    
    it "should abandon the session" do
      @session = mock("session", :null_object => true)
      @session.should_receive(:abandon!)
      dispatch(:unauthenticated){|c| c.stub!(:session).and_return(@session) }
    end
  end
  
  
end