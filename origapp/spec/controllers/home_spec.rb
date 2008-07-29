require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Home, "index action" do
  before(:each) do
    dispatch_to(Home, :index)
  end
end