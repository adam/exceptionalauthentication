# 
# Mixin for the Merb::DataMapperSession which provides for authentication
# 
module Authentication
  module Session
    
    ##
    # @return [TrueClass, FalseClass]
    # 
    def authenticated?
      !user.nil?
    end

    ##
    # returns the active user for this session, or nil if there's no user claiming this session
    # @returns [User, NilClass]
    def user
      @user ||= self[:user_id].blank? ? nil : User.get(self[:user_id])
    end
    
    ## 
    # allows for manually setting the user
    # @returns [User, NilClass]
    def user=(user)
      case user
      when User
        self[:user_id] = user.id
        @user = user
      else
        abandon!
      end
      @user
    end

    ##
    # retrieve the claimed identity and verify the claim
    # 
    # @param login [String] user's claimed identity
    # @param password [String] password to verify against the claimed identity
    # @return [User, NilClass] the verified user, or nil if verification failed
    # @see User::encrypt
    # 
    def authenticate(login, password)
      if login && password
        possible_user = ::User.first(:login => login, :active => true) 
        Merb.logger.info! "Claimed Identity: #{possible_user.inspect}"
        self.user = possible_user if possible_user && possible_user.crypted_password == User.encrypt(possible_user.salt, password)
      end
    end

    ##
    # abandon the session, log out the user, and empty everything out
    # 
    def abandon!
      @user = nil
      delete
      self
    end
    
  end
end