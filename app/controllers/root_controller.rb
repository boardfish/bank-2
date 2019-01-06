class RootController < ApplicationController
  def index
    @monzo_login_url = monzo_login_url
    if session[:access_token]
      MonzoService.authenticate(session[:access_token])
      # May want to do things with this.
      @account = MonzoService.default_account
      @pots = MonzoService.pots
      @transactions = MonzoService.transactions_by_month(months_back: params[:months_back].to_i || 0)
      @balance = MonzoService.balance
      @grouped_transactions = total_spend_by_category(@transactions)
      @monthly_summary = (0..11).to_a.reverse.map { |months_back| total_spend_by_category(MonzoService.transactions_by_month(months_back: months_back)) }
      @categories = MonzoService.transactions.map { |transaction| transaction.metadata[:oauth2client_00009eUNchi7jOqB10g2yX_category] || transaction.category}.uniq
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

  def set_category
    Monzo::Transaction.create_annotation(
      params[:transaction_id], 
      { oauth2client_00009eUNchi7jOqB10g2yX_category: params[:category].gsub(/[^0-9a-z_]/i, '').downcase }
    )
    flash[:notice] = 'Transaction category set successfully.'
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

  def total_spend_by_category(transactions)
    transactions
      .group_by { |transaction| transaction.metadata[:oauth2client_00009eUNchi7jOqB10g2yX_category] || transaction.category }
      .map { |category, transactions| [category, transactions.sum { |transaction| transaction.amount }]}.to_h
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
