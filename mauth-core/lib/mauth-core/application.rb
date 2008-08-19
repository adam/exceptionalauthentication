class Application < Merb::Controller
  include Merb::AuthenticatedHelper
  before :ensure_authentication
  
end