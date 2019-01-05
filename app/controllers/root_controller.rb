class RootController < ApplicationController
  def index
    @monzo_login_url = monzo_login_url
    if session[:access_token]
      Monzo.configure(session[:access_token])
      # May want to do things with this.
      # TODO: Is there a nice way to see if an account is closed?
      # @accounts = Monzo::Account.all
      # @pots = Monzo::Pot.all
      # @transactions = Monzo::Transaction.all(@accounts.last.id)
    end
  end

  def callback
    @state = params[:state]
    @response = connection.post '/oauth2/token', URI.encode_www_form({
      grant_type: 'authorization_code',
      client_id: 'oauth2client_00009eUNchi7jOqB10g2yX',
      client_secret: ENV.fetch('MONZO_CLIENT_SECRET'),
      redirect_uri: 'http://localhost:3000/callback',
      code: params[:code]
    })
    session[:access_token] = JSON.parse(@response.body)['access_token']
    flash[:notice] = 'Logged in successfully.'
    redirect_to root_path
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

  def connection(raise_error: false, token: nil)
    Faraday.new(url: 'https://api.monzo.com/') do |faraday|
      faraday.use Faraday::Response::RaiseError if raise_error
      faraday.adapter Faraday.default_adapter
      faraday.headers['Authorization'] = "Bearer #{token}" if token
      faraday.request  :url_encoded             # form-encode POST params
    end
  end
end
