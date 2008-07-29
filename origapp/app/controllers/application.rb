class Application < Merb::Controller
  
  before :ensure_authentication
  
  protected
  def ensure_authentication
    raise(Unauthenticated, 'Please Log In') unless session.authenticated?
  end
  
end