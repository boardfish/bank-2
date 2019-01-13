module BudgetsService
  class << self
    def for(monzo_account_id)
      db_connection.hkeys(monzo_account_id).map { |category| [category, db_connection.hget(monzo_account_id, category)] }.to_h
    end

    def set(account_id:, category:, budget:)
      db_connection.hset(account_id, "budget_#{category}", budget)
    end

    def db_connection
      Redis.new(:host => "db", :port => 6379, :db => 15)
    end
  end
end