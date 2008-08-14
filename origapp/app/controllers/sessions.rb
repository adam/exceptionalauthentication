class Sessions < Application

  skip_before :ensure_authenticated
  
  after :update do
    # redirect from an after filter for max flexibility
    # We can then put it into a slice and ppl can easily 
    # customize the action
    redirect url(:home), :message => "Authenticated Successfully"
  end

  def update(login, password)
    session.authenticate(self)
    "Add an after filter to #{controller.class.name} to redirect after login"
  end
  
  def destroy
    session.abandon!
    raise Unauthenticated, "Thank you, come again - Apu Nahasapeemapetilon"
  end
  
end
