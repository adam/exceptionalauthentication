module Merb
  class Controller::Unauthenticated < ControllerExceptions::Unauthorized; end
  
  module AuthenticationHelper  
    protected
    # Check to see if a user is logged in
    def ensure_authentication
      raise(Merb::Controller::Unauthenticated, 'Please Log In') unless session.authenticated?
    end 
  end
end