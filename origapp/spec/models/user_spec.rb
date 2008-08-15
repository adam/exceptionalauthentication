require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe User do
  before do
    @user = User.new
  end

  it{@user.should respond_to(:active?)}

end