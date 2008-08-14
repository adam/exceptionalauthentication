# 
# Mixin for the Merb::DataMapperSession which provides for authentication
# 
module Authentication
  class DuplicateStrategy < Exception; end
  class MissingStrategy < Exception; end
  class NotImplemented < Exception; end
  
  class StrategyContainer    
    include Enumerable
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
    
    def clear!
      @order = []
      @strategies = {}
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
  
  
  @@login_strategies = Hash.new{|h,k| h[k] = StrategyContainer.new }

  def self.login_strategies(phase)
    @@login_strategies[phase]
  end
  
  class Manager
    include Extlib::Hook
    attr_accessor :session
    
    def initialize(session)
      @session = session
    end
    
    ##
    # @return [TrueClass, FalseClass]
    # 
    def authenticated?
      !!user
    end
    
    ##
    # returns the active user for this session, or nil if there's no user claiming this session
    # @returns [User, NilClass]
    def user
      return nil if !session[:user]
      @user ||= fetch_user(session[:user])
    end
    
    ## 
    # allows for manually setting the user
    # @returns [User, NilClass]
    def user=(user)
      session[:user] = store_user(user)
      @user = session[:user] ? user : session[:user]  
    end
    
    ##
    # retrieve the claimed identity and verify the claim
    # 
    # Uses the strategies setup on Authentication executed in the context of the controller to see if it can find
    # a user object
    # @return [User, NilClass] the verified user, or nil if verification failed
    # @see User::encrypt
    # 
    def authenticate(controller, opts = {})
      msg = opts.delete(:message) || "Could Not Log In"
      user = nil    
      # This one should find the first one that matches.  It should not run antother
      Authentication.login_strategies(:find).detect do |s|
        user = controller.instance_eval(&s)
      end
      raise Merb::Controller::Unauthenticated, msg unless user
      self.user = user
    end
    
    ##
    # abandon the session, log out the user, and empty everything out
    # 
    def abandon!
      @user = nil
      session.delete
    end
    
    # Overwrite this method to store your user object in the session.  The return value of the method will be stored
    def store_user(user)
      raise NotImplemented
    end
    
    # Overwrite this method to fetch your user from the session.  The return value of this will be stored as the user object
    # return nil to stop login
    def fetch_user(session_contents = session[:user])
      raise NotImplemented
    end
    
  end
  
  module Session
    
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend,  ClassMethods)
      base.class_eval do
        include Extlib::Hook
        attr_accessor :_authentication_manager
        
        after_class_method :new do |instance, *args|
          instance._authentication_manager = Authentication::Manager.new(instance)
        end
      end
      
    end
    
    module ClassMethods    
    end # ClassMethods
    
    module InstanceMethods
      def authenticated?
        _authentication_manager.authenticated?
      end
      
      def authenticate(controller)
        _authentication_manager.authenticate(controller)
      end
      
      def user
        _authentication_manager.user
      end
      
      def user=(the_user)
        _authentication_manager.user = the_user
      end
      
      def abandon!
        _authentication_manager.abandon!
      end
      
    end # InstanceMethods
    
  end # Session
end