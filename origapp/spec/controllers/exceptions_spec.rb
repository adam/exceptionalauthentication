require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Exceptions do
  before(:each) do
    @user = mock("user", :null_object => true)
  end
  
  def dispatch(action, options = {}, env = {}, &blk)
    dispatch_to(Exceptions, action, options, env, &blk)
  end
  
  describe "unauthenticated" do  
    it "should redirect to :login" do
      dispatch(:unauthenticated).should redirect_to(url(:login))
    end
  end
  
  
end