# 
# Mixin for the Merb::DataMapperSession which provides for authentication
# 
module Authentication
  class DuplicateStrategy < Exception; end
  class MissingStrategy < Exception; end
  class NotImplemented < Exception; end
  
  class StrategyContainer    
    attr_reader :order, :strategies
    include Enumerable
    
    def initialize
      @order = []
      @strategies = {}
    end
    
    # Add a new strategy with the given name
    def add(label, options = {}, &blk)
      raise DuplicateStrategy, "The #{label} strategy is already defined in this list" unless strategies[label].nil?
      strategies[label] = blk
      order << label
    end
    
    # Removed the specified strategy
    def remove(label)
      raise MissingStrategy, "The #{label} strategy does not exist" if strategies[label].nil?
      order.delete(label)
      strategies.delete(label)
    end
    
    # Allows you to change the order of the execution of the strategies
    def order=(new_order)
      raise ArgumentError, "Pass an Array to StrategyContainer#order=" unless new_order.kind_of?(Array)
      raise MissingStrategy, "The strategy does not exist" unless (new_order - strategies.keys).empty?
      raise DuplicateStrategy, "The same strategy may not be specified to run twice" if new_order.size != new_order.uniq.size
      @order = new_order
    end
    
    # Clear all strategies
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

  # Gets the active strategy containers.  By defualt there are 
  # :pre_find  - executes all strategies prior to looking for a  user model
  # :find      - executes to find the user model.  The block should return a user object or nil
  # :post_find - executes after the finder to confirm that a user is allowed.   
  def self.login_strategies(phase)
    @@login_strategies[phase]
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
        return nil if !self[:user]
        @user ||= fetch_user(self[:user])
      end
    
      ## 
      # allows for manually setting the user
      # @returns [User, NilClass]
      def user=(user)
        self[:user] = store_user(user)
        @user = self[:user] ? user : self[:user]  
      end

      ##
      # retrieve the claimed identity and verify the claim
      # 
      # Uses strategies to find and confirm that a user is valid.  A user could be anything, and you should setup the store_user, and fetch_user
      # to set what you consider a "User" object.  
      # 
      # There are 3 strategy groups that are run for authenticate.  
      # 
      # 1. :pre_find - These are run concecutively with no tests for completion.  These are for setup only
      # 2. :find     - This group is where the user model is found.  The strategy should return a user object if it finds one.  Otherwise it should
      #                return nil or false.  The first strategy whose results evaluate to not nil/false will be set as the user object.  This
      #                is executed in the context of the controller.
      # 3. :post_find - This group is where confirmation is completed on the user model.  For example.  Is the user active? Have they had too many login attempts etc
      #                 To allow the user to proceed, return the user.  To halt the user, return nil or false.  Each of these strategies will be yielded the user object and the
      #                 controller object
      #
      # See Authentication::StrategyContainer for more methods
      def authenticate(controller)
        user = nil
        # Runs the pre finder strategies
        Authentication.login_strategies(:pre_find).each{|s| s.call }
        
        # This one should find the first one that matches.  It should not run antother
        Authentication.login_strategies(:find).detect do |s|
          user = controller.instance_eval(&s)
        end
        raise Merb::Controller::Unauthenticated unless user
        
        # Runs any post find processing.  e.g. check for an active user, check for forgotten passwords etc.
        # Stops after the first time a user is not found after the strategy is run
        user = Authentication.login_strategies(:post_find).inject(user){|user, s| u = s.call(user, controller); break unless u; u}   
        raise Merb::Controller::Unauthenticated unless user
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
      
      # Overwrite this method to store your user object in the session.  The return value of the method will be stored
      def store_user(user)
        raise NotImplemented
      end
      
      # Overwrite this method to fetch your user from the session.  The return value of this will be stored as the user object
      # return nil to stop login
      def fetch_user(session_contents = self[:user])
        raise NotImplemented
      end
    end # InstanceMethods
    
  end # Session
end