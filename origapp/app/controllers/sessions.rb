class Sessions < Application

  skip_before :ensure_authentication
  
  def edit
    render
  end

  def update(login, password)
    if session.authenticate(login, password)
      redirect url(:home)
    else
      raise Unauthenticated, 'Authentication Failed. Please Try Again'
    end
  end
  
  def destroy
    session.abandon!
    raise Unauthenticated, "Thank you, come again ~ Apu Nahasapeemapetilon"
  end
  
end
