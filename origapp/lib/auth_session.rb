module Authentication
  module Session
    def authenticated?
      !user.nil?
    end

    def user
      @user ||= self[:user_id].blank? ? nil : User.get(self[:user_id])
    end

    def authenticate(login, password)
      unless login.nil? || password.nil?
        possible_user = ::User.first(:login => login, :active => true) 
        
        @user = possible_user if possible_user.crypted_password == User.encrypt(possible_user.salt, password)
        
        self.data = {}
        self[:user_id] = @user.id if @user
        @user
      else
        nil
      end
    end

    def abandon!
      @user = nil
      self.data = {}
      self.save
      self
    end
  end
end