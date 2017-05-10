require "dawanda_money/version"

module DawandaMoney
  class Money
    attr_reader :amount, :currency

    @@conversion_rates = {}

    def self.conversion_rates(base_currency, rates)
      base_currency = base_currency.to_s
      rates = rates.to_h
      rates = rates.map do |k, v|
        raise "Wrong rate: #{v}" if v.to_f.zero?
        [k.to_s, v.to_f]
      end.to_h

      @@conversion_rates[base_currency] = rates
    end

    def initialize(amount, currency)
      raise "Wrong amount: #{amount}, it should be Integer or Float" unless amount.is_a? Numeric
      @amount = amount
      @currency = currency.to_s
    end

    def inspect
      "#{'%.2f' % amount} #{currency}"
    end
  end
end
