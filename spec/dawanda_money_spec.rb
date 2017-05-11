require 'spec_helper'

describe DawandaMoney do
  it 'has a version number' do
    expect(DawandaMoney::VERSION).not_to be nil
  end

  describe 'conversion rates' do
    context 'raise error' do
      it 'rate is zero' do
        expect do
          DawandaMoney::Money.conversion_rates('EUR', {'USD' => 0.0, 'Bitcoin' => 0.0047})
        end.to raise_error(Exception)
      end

      it 'rate is not numeric' do
        expect do
          DawandaMoney::Money.conversion_rates('EUR', {'USD' => 'GF3564f', 'Bitcoin' => 0.0047})
        end.to raise_error(Exception)
      end
    end

    it 'fill class variable' do
      DawandaMoney::Money.conversion_rates('EUR', {'USD' => 1.11, 'Bitcoin' => 0.0047})
      DawandaMoney::Money.conversion_rates('USD', {'HRN' => 26.30, 'RUR' => 67.25})
      expected_value = {
          'EUR' => { 'USD' => 1.11,
                     'Bitcoin' => 0.0047 },
          'USD' => { 'EUR' => 0.9009009009009008,
                     'HRN' => 26.3,
                     'RUR' => 67.25 },
          'Bitcoin' => { 'EUR' => 212.7659574468085 },
          'HRN' => { 'USD' => 0.03802281368821293,
                     'EUR' => 0.03425478710649813 },
          'RUR' => { 'USD' => 0.01486988847583643,
                     'EUR' => 0.013396295924176963 }
      }

      expect(DawandaMoney::Money.class_variable_get :@@conversion_rates).to eq(expected_value)
    end
  end

  describe 'instantiate object' do
    context 'raise error' do
      it 'amount is not numeric' do
        expect do
          DawandaMoney::Money.new('EUdscfdsR', 'EUR')
        end.to raise_error(Exception)
      end
    end

    context 'reader methods' do
      subject { DawandaMoney::Money.new(50, 'EUR') }

      it 'amount reader' do
        expect(subject.amount).to eq(50)
      end

      it 'currency reader' do
        expect(subject.currency).to eq('EUR')
      end

      it 'inspect' do
        expect(subject.inspect).to eq('50.00 EUR')
      end
    end
  end

  describe 'convert_to' do
    
  end

end
