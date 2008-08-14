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
    session.abandon!
    msg = params[:exception] ? params[:exception].message : 'Please Log In'
    redirect url(:login), :message => msg
  end

  def not_acceptable
    render :format => :html
  end

end