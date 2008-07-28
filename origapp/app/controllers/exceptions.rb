class Unauthenticated < Merb::ControllerExceptions::Unauthorized; end

class Exceptions < Application
  
  skip_before :logged_in?
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  # login page
  def unauthorized
    render :format => :html
  end
  
  def unauthenticated
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

end