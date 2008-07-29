##
# HTTP confuses authENTICATION and authORIZATION a little bit, 
# so to help ourselves out, we create a custom exception which
# helps keep semantics clear
# 
class Exceptions < Application
  
  skip_before :ensure_authentication
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  def unauthorized
    redirect url(:login)
  end

  # login page
  def unauthenticated
    redirect url(:login)
  end

  def not_acceptable
    render :format => :html
  end

end