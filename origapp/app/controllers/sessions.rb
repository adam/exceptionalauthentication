class Sessions < Application

  skip_before :logged_in?

  def update(login, password)
    if session.authenticate(login, password)
      redirect url(:projects)
    else
      raise Unauthenticated, 'Authentication Failed. Please Try Again'
    end
  end
  
  def edit
    render
  end
  
  def destroy
    session.abandon!
    raise Unauthenticated
  end
  
end
