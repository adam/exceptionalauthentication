class Application < Merb::Controller
  
  before :logged_in?
  protected
  def logged_in?
    raise(Unauthenticated, 'Please Log In') unless session.authenticated?
  end
end