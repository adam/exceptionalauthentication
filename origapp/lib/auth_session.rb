# 
# Mixin for the Merb::DataMapperSession which provides for authentication
# 
module Authentication
  @@login_strategies = {}
  @@active_strategies = []
  
  def self.reset_strategies_to_default!
    login_strategies.clear
    active_strategies.clear
    
    add_login_strategy(:salted_login) do 
      user = User.first(:login => params[:login])
      if user && user.crypted_password == User.encrypt(user.salt, params[:password])
        user
      else
        nil
      end
    end
  end # reset_strategies_to_default!
  
  def self.add_login_strategy(label, &block)
    login_strategies[label] = block
    active_strategies << label unless active_strategies.include?(label)
  end #add_login_strategy
  
  def self.remove_login_strategy!(label)
    login_strategies.delete(label)
    active_strategies.reject!{|s| s == label}
  end
  
  def self.login_strategies
    @@login_strategies
  end #login_strategies
  
  def self.active_strategies
    @@active_strategies
  end
  
  def self.active_strategies=(set)
    raise "Should be an Array like object" unless set.respond_to?(:each)
    raise "Active Strategies should not be empty" if set.empty?
    raise "Strategy Not Registered" unless (set - @@active_strategies).empty?
    @@active_strategies = set
  end
  
  module Session
    
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend,  ClassMethods)
    end
    
    module ClassMethods    
    end # ClassMethods
    
    module InstanceMethods
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
    end # InstanceMethods
    
  end # Session
end