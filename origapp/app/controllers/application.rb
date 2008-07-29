class Application < Merb::Controller
  
  before :ensure_authentication
  
end