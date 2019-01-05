class RootController < ApplicationController
  def index
    @monzo_login_url = monzo_login_url
  end

  def callback
    @code = params[:code]
    @state = params[:state]
  end

  def logout
  end

  def monzo_login_url
    'https://auth.monzo.com/' \
    "?client_id=oauth2client_00009eUNchi7jOqB10g2yX" \
    "&redirect_uri=#{CGI.escape 'http://localhost:3000/callback'}" \
    '&response_type=code' \
    '&state=foobar'
  end
end
