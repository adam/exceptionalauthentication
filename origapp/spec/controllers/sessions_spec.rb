require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Sessions do
  describe "routes" do
    it "should have a :login route" do
      request_to(url(:login)).should route_to(Sessions, :edit)
    end
    
    it "should have a :logout route" do
      request_to(url(:logout)).should route_to(Sessions, :destroy)
    end
  end
  
  describe "Session object" do
    
    
  end 
end