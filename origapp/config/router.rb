Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  
  r.match("/login"  ).to(:controller => "sessions", :action  => 'edit'     ).name(:login)
  r.match("/logout").to(:controller => "sessions", :action   => 'destroy'  ).name(:logout)

  r.default_routes

  r.match('/').to(:controller => 'home', :action =>'index').name(:home)
end