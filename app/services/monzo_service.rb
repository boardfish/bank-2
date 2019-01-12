module MonzoService
  class << self
    def authenticate(access_token)
      Monzo.configure(access_token)
    end

    def transactions_by_month(months_back: 0)
      month = DateTime.now.months_ago(months_back)
      load_transactions(from: month.beginning_of_month, to: month.end_of_month)
    end

    def load_transactions(from: nil, to: nil)
      loaded_transactions = transactions.reverse
      loaded_transactions = loaded_transactions.select { |transaction| transaction.created <= to } if to
      loaded_transactions = loaded_transactions.select { |transaction| transaction.created >= from } if from
      loaded_transactions
    end
    
    def transactions
      @transactions ||= Monzo::Transaction.all(default_account.id)
    end

    def balance(account: default_account)
      Monzo::Balance.find(account.id)
    end

    def pots
      Monzo::Pot.all.reject { |pot| pot.deleted }
    end

    def default_account
      Monzo::Account.all.last
    end

    def balance_on(date)
      balance.balance - load_transactions(from: date).reduce(0) { |sum, transaction| sum + transaction.amount }
    end
  end
end