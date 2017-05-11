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
        raise "Wrong rate: #{v}" if v.to_f.zero?
        [k.to_s, v.to_f]
      end.to_h

      @@conversion_rates[base_currency] ||= {}
      @@conversion_rates[base_currency].merge!(rates)
      rates.each do |k, v|
        @@conversion_rates[k] ||= {}
        @@conversion_rates[k].merge!({base_currency => (1 / v)})
        if base_currency != BASE_CURRENCY &&
           @@conversion_rates[base_currency] &&
           @@conversion_rates[base_currency][BASE_CURRENCY]
          @@conversion_rates[k].merge!({BASE_CURRENCY => (@@conversion_rates[base_currency][BASE_CURRENCY] / v) })
        end
      end
    end

    def initialize(amount, currency)
      raise "Wrong amount: #{amount}, it should be Integer or Float" unless amount.is_a? Numeric
      @amount = amount
      @currency = currency.to_s
    end

    def inspect
      "#{'%.2f' % amount} #{currency}"
    end

    def convert_to(cur)
      return self if currency == cur

      if @@conversion_rates[currency] && (rate = @@conversion_rates[currency][cur])
        Money.new((amount * rate).round(2), cur)
      elsif @@conversion_rates[currency] &&
            @@conversion_rates[currency][BASE_CURRENCY] &&
            @@conversion_rates[BASE_CURRENCY] &&
            @@conversion_rates[BASE_CURRENCY][cur]
        convert_to(BASE_CURRENCY).convert_to(cur)
      else
        raise "Error: no rates to convert #{currency} to #{cur}" if rate.nil?
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
  end
end
