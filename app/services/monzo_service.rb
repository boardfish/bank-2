module MonzoService
  class << self
    def authenticate(access_token)
      Monzo.configure(access_token)
    end

    def transactions_by_month(months_back: 0)
      month = DateTime.now.months_ago(months_back)
      transactions(from: month.beginning_of_month, to: month.end_of_month)
    end

    def transactions(from: nil, to: nil, account: default_account)
      transactions = Monzo::Transaction.all(account.id)
        .reverse
      transactions = transactions.select { |transaction| transaction.created <= to } if to
      transactions = transactions.select { |transaction| transaction.created >= from } if from
      transactions
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
  end
end