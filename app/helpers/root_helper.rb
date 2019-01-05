module RootHelper
  def authenticated?
    session[:access_token]
  end
end
