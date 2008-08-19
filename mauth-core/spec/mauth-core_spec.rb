require File.dirname(__FILE__) + '/spec_helper'

describe "mauth-core" do
  it "should do something" do
    a = Application.new('', {})
    a.should respond_to(:ensure_authentication)
  end
end