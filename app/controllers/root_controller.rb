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
      @monthly_balance = (0..11).to_a.map { |months_back| MonzoService.balance_on(Date.today.at_beginning_of_month.days_ago(1).months_ago(months_back).to_time.to_datetime) }
      @categories = MonzoService.transactions.map { |transaction| transaction.metadata["#{@client_id}_category".to_sym] || transaction.category}.uniq
      @budgets = BudgetsService.for(@account.id)
    end
  end

  def callback
    @state = params[:state]
    @response = connection.post '/oauth2/token', URI.encode_www_form({
      grant_type: 'authorization_code',
      client_id: ENV.fetch('MONZO_CLIENT_ID'),
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
      { "#{@client_id}_category" => params[:category].parameterize.tr("-", "_") }
    )
    flash[:notice] = 'Transaction category set successfully.'
    redirect_to root_path
  end

  def set_budget
    BudgetsService.set(account_id: MonzoService.default_account.id, category: params[:category], budget: params[:budget].to_i)
    flash[:notice] = 'Category budget set successfully.'
    redirect_to root_path
  end

  def logout
  end

  def monzo_login_url
    'https://auth.monzo.com/' \
    "?client_id=#{ENV.fetch('MONZO_CLIENT_ID')}" \
    "&redirect_uri=#{CGI.escape 'http://localhost:3000/callback'}" \
    '&response_type=code' \
    '&state=foobar'
  end

  def total_spend_by_category(transactions)
    transactions
      .group_by { |transaction| transaction.metadata["#{@client_id}_category".to_sym] || transaction.category }
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
