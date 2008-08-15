Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  
  r.match("/logout").to(:controller => "sessions", :action   => 'destroy'  ).name(:logout)
  r.match("/login", :method => :put).to(:controller => "sessions", :action => "update")
  r.match("/login", :method => :get).to(:controller => "exceptions", :action => "unauthenticated").name(:login)

  r.default_routes

  r.match('/').to(:controller => 'home', :action =>'index').name(:home)
end