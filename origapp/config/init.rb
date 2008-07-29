Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

Merb.push_path(:lib, Merb.root / "lib")

dependencies 'dm-validations'
dependencies 'merb-assets', 'merb_helpers', 'merb-action-args'

Merb::BootLoader.after_app_loads do
  require "merb/session/data_mapper_session"
  
  # ORM logging
  DataObjects::Sqlite3.logger = DataObjects::Logger.new(STDOUT, 0) 
  
  # ORM migration
  Merb::DataMapperSession.auto_migrate!
  User.auto_migrate!
  
  # Creating the first user
  User.create(
    :login => 'admin',
    :email => 'admin@foo.com',
    :password => 'sekrit',
    :password_confirmation => 'sekrit',
    :active => true)
  
end

use_orm :datamapper
use_test :rspec

Merb::Config.use do |c|
  c[:session_secret_key]  = 'd3a6e6f99a25004da82b71af8b9ed0ab71d3ea21'
end

# injecting Merb::DataMapperSession with authentication extensions
class Merb::BootLoader::AuthenticatedSessions < Merb::BootLoader
  after MixinSessionContainer
  
  def self.run
    # Very kludgy way to get at the sessions object in include the new stuff
    Merb.logger.info "Mixing in Authentication Session into the session object"
    controller = Application.new(Merb::Request.new({}))
    controller.setup_session
    controller.session.class.send(:include,  Authentication::Session)    
  end
  
end