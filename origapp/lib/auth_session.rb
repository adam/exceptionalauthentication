# 
# Mixin for the Merb::DataMapperSession which provides for authentication
# 
module Authentication
  class DuplicateStrategy < Exception; end
  class MissingStrategy < Exception; end
  
  class StrategyContainer    
    attr_reader :order, :strategies
    
    def initialize
      @order = []
      @strategies = {}
    end
    
    def add(label, options = {}, &blk)
      raise DuplicateStrategy, "The #{label} strategy is already defined in this list" unless strategies[label].nil?
      strategies[label] = blk
      order << label
    end
    
    def remove(label)
      raise MissingStrategy, "The #{label} strategy does not exist" if strategies[label].nil?
      order.delete(label)
      strategies.delete(label)
    end
    
    def order=(new_order)
      raise ArgumentError, "Pass an Array to StrategyContainer#order=" unless new_order.kind_of?(Array)
      raise MissingStrategy, "The strategy does not exist" unless (new_order - strategies.keys).empty?
      raise DuplicateStrategy, "The same strategy may not be specified to run twice" if new_order.size != new_order.uniq.size
      @order = new_order
    end
    
    def [](key)
      strategies[key]
    end
    
    def each
      order.each do |label|
        yield strategies[label] if block_given?
      end
    end
  end
  
  
  @@login_strategies = {}
  @@active_login_strategies = []
  
  def self.reset_strategies_to_default!
    login_strategies.clear
    active_login_strategies.clear
    
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
    active_login_strategies << label unless active_login_strategies.include?(label)
  end #add_login_strategy
  
  def self.remove_login_strategy!(label)
    login_strategies.delete(label)
    active_login_strategies.reject!{|s| s == label}
  end
  
  def self.login_strategies
    @@login_strategies
  end #login_strategies
  
  def self.active_login_strategies
    @@active_login_strategies
  end
  
  def self.active_login_strategies=(set)
    raise "Should be an Array like object" unless set.respond_to?(:each)
    raise "Active Strategies should not be empty" if set.empty?
    raise "Strategy Not Registered" unless (set - @@active_login_strategies).empty?
    @@active_login_strategies = set
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
      # Uses the strategies setup on Authentication executed in the context of the controller to see if it can find
      # a user object
      # @return [User, NilClass] the verified user, or nil if verification failed
      # @see User::encrypt
      # 
      def authenticate(controller)
        user = nil
        Authentication.active_login_strategies.detect do |strategy|
          block = Authentication.login_strategies[strategy]
          next unless block
          user = controller.instance_eval(&block)
        end
        # need to put the post authenticated tests here for things like 
        # activated, forgotten passwords etc        
        self.user = user
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
  
  reset_strategies_to_default!
end