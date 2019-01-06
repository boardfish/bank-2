module RootHelper
  def authenticated?
    session[:access_token]
  end

  def category(transaction)
    category = transaction.metadata[:oauth2client_00009eUNchi7jOqB10g2yX_category] || transaction.category
    category.humanize
  end
end
