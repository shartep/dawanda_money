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
        raise "Error: no rates to convert #{currency} to #{cur}" if rate.nil?
        rate = rate[cur]
        raise "Error: no rates to convert #{currency} to #{cur}" if rate.nil?

        Money.new((amount * rate).round(2), cur)
      else
        convert_to_base.convert_to(cur)
      end
    end

    [:+, :-, :*, :/].each do |operator|
      define_method operator do |other|
        if other.is_a?(Numeric)
          Money.new(amount.public_send(operator, other), currency)
        elsif other.is_a?(DawandaMoney::Money)
          Money.new(amount.public_send(operator, other.convert_to(currency).amount), currency)
        else
          raise "Wrong type of second argument: #{other.class}. Should be Integer, Float or Money"
        end
      end
    end

    [:==, :>, :<, :>=, :<=].each do |operator|
      define_method operator do |other|
        if other.is_a?(Numeric)
          amount.public_send(operator, other)
        elsif other.is_a?(DawandaMoney::Money)
          amount.public_send(operator, other.convert_to(currency).amount)
        else
          raise "Wrong type of second argument: #{other.class}. Should be Integer, Float or Money"
        end
      end
    end

    private

    def convert_to_base
      rate = @@conversion_rates[BASE_CURRENCY]
      raise "Error: no rates to convert #{currency} to #{BASE_CURRENCY}" if rate.nil?
      rate = rate[currency]
      raise "Error: no rates to convert #{currency} to #{BASE_CURRENCY}" if rate.nil?

      Money.new((amount / rate).round(2), BASE_CURRENCY)
    end
  end
end
