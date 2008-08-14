class Sessions < Application

  skip_before :ensure_authenticated
  
  # redirect from an after filter for max flexibility
  # We can then put it into a slice and ppl can easily 
  # customize the action
  after nil, :only => :update do
    redirect url(:home), :message => "Authenticated Successfully"
  end
  
  after nil, :only => :destroy do
    raise Unauthenticated, "Thank you, come again - Apu Nahasapeemapetilon"
  end

  def update(login, password)
    session.authenticate(self)
    "Add an after filter to #{controller.class.name} to redirect after login"
  end
  
  def destroy
    session.abandon!
  end
  
end
