require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Merb::AuthenticationHelper do
  
  class ControllerMock
    include Merb::AuthenticationHelper
  end
  
  before(:each) do
    @controller = ControllerMock.new
    @session = mock("session")
    @controller.stub!(:session).and_return(@session)
    @session.stub!(:authenticated?).and_return(true)
  end
  
  it "should not raise and Unauthenticated error" do
    lambda do
      @controller.send(:ensure_authentication)
    end.should_not raise_error(Merb::Controller::Unauthenticated)
  end
  
  it "should raise an Unauthenticated error" do
    @session.should_receive(:authenticated?).and_return(false)
    lambda do
      @controller.send(:ensure_authentication)
    end.should raise_error(Merb::Controller::Unauthenticated)
  end
  
end