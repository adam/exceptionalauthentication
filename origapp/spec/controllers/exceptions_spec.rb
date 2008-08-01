require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Exceptions do
  before(:each) do
    @user = mock("user", :null_object => true)
  end

  it "should route login to unauthenticated" do
    request_to(url(:login)).should route_to(Exceptions, :unauthenticated)
  end

end