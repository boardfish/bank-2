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
    end
  end
end
