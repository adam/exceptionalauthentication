Authentication.login_strategies.add(:dm_salted_login_from_form) do
  User.authenticate(params[:login], params[:password])
end

Authentication.login_strategies.add(:dm_salted_login_basic_auth) do
  basic_authentication.authenticate do |login, password|
    User.authenticate(login, password)
  end
end