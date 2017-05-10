require "dawanda_money/version"

module DawandaMoney
  class Money
    BASE_CURRENCY = 'EUR'

    attr_reader :amount, :currency

    @@conversion_rates = {}

    def self.conversion_rates(base_currency, rates)
      base_currency = base_currency.to_s
      rates = rates.to_h
      rates = rates.map do |k, v|
        return "Wrong rate: #{v}" if v.to_f.zero?
        [k.to_s, v.to_f]
      end.to_h

      @@conversion_rates[base_currency] = rates
    end

    def initialize(amount, currency)
      return "Wrong amount: #{amount}, it should be Integer or Float" unless amount.is_a? Numeric
      @amount = amount
      @currency = currency.to_s
    end

    def inspect
      "#{'%.2f' % amount} #{currency}"
    end

    def convert_to(cur)
      if currency == cur
        self
      elsif currency == BASE_CURRENCY
        rate = @@conversion_rates[BASE_CURRENCY]
        return "Error: no rates to convert #{currency} to #{cur}" if rate.nil?
        rate = rate[cur]
        return "Error: no rates to convert #{currency} to #{cur}" if rate.nil?

        Money.new(amount * rate, cur)
      else
        convert_to_base.convert_to(cur)
      end
    end

    private

    def convert_to_base
      rate = @@conversion_rates[BASE_CURRENCY]
      return "Error: no rates to convert #{currency} to #{BASE_CURRENCY}" if rate.nil?
      rate = rate[currency]
      return "Error: no rates to convert #{currency} to #{BASE_CURRENCY}" if rate.nil?

      Money.new(amount / rate, BASE_CURRENCY)
    end
  end
end
