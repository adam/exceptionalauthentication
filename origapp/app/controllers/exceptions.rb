##
# HTTP confuses authENTICATION and authORIZATION a little bit, 
# so to help ourselves out, we create a custom exception which
# helps keep semantics clear
# 
class Exceptions < Application
  
  skip_before :ensure_authenticated
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  def unauthorized
    unauthenticated
  end

  # login page
  def unauthenticated
    provides :xml
    session.abandon!
    case content_type
    when :xml
      basic_authentication.request
    when :html 
      render
    else
      display({}) # display the form for html... report that the user isn't logged in otherwise
    end
  end

  def not_acceptable
    render :format => :html
  end

end