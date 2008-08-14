module Merb
  class Controller::Unauthenticated < ControllerExceptions::Unauthorized; end
  
  module AuthenticationHelper  
    protected
    # Check to see if a user is logged in
    def ensure_authenticated
      session.authenticate(self)
    end 
  end
end