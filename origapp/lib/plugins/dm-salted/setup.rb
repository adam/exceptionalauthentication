require 'auth_session'
module Authentication
  class Manager
    after :authenticate do |instance, *args|
      raise Merb::Controller::Unauthenticated, "User Not Active" unless instance.active?
    end
    
    def store_user(user)
      return nil unless user
      user.id
    end
    
    def fetch_user(session_info)
      User.get(session_info)
    end
    
  end  
end # Authentication