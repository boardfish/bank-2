module RootHelper
  def authenticated?
    session[:access_token]
  end

  def category(transaction)
    category = transaction.metadata[:oauth2client_00009eUNchi7jOqB10g2yX_category] || transaction.category
    category.humanize
  end

  def to_currency(object)
    if object.is_a?(Monzo::Transaction)
      Money.new(object.amount, object.currency).format
    elsif object.is_a?(Monzo::Pot) or object.is_a?(Monzo::Balance)
      Money.new(object.balance, object.currency).format
    elsif object.is_a?(Integer)
      Money.new(object, 'GBP').format
    end
  end

  def link_to_previous_month
    link_to "<", root_path(months_back: params[:months_back].to_i + 1)
  end

  def link_to_next_month
    link_to ">", root_path(months_back: params[:months_back].to_i - 1)
  end
end
