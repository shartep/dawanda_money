require 'spec_helper'

describe DawandaMoney do
  it 'has a version number' do
    expect(DawandaMoney::VERSION).not_to be nil
  end

  let(:fifty_eur)       { DawandaMoney::Money.new(50, 'EUR') }
  let(:twenty_dollars)  { DawandaMoney::Money.new(20, 'USD') }
  let(:ten_bitco)       { DawandaMoney::Money.new(10, 'Bitcoin') }
  let(:hundred_hrn)     { DawandaMoney::Money.new(100, 'HRN') }
  let(:thousand_rur)    { DawandaMoney::Money.new(1000, 'RUR') }

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
                     'Bitcoin' => 0.0047,
                     'HRN' => 29.193000000000005,
                     'RUR' => 74.64750000000001 },
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
    before :each do
      DawandaMoney::Money.conversion_rates('EUR', {'USD' => 1.11, 'Bitcoin' => 0.0047})
      DawandaMoney::Money.conversion_rates('USD', {'HRN' => 26.30, 'RUR' => 67.25})
    end

    it 'EUR to USD' do
      expect(fifty_eur.convert_to('USD')).to eq(DawandaMoney::Money.new(55.5, 'USD'))
    end

    it 'USD to EUR' do
      expect(twenty_dollars.convert_to('EUR')).to eq(DawandaMoney::Money.new(18.02, 'EUR'))
    end

    it 'USD to Bitcoin' do
      expect(twenty_dollars.convert_to('Bitcoin')).to eq(DawandaMoney::Money.new(0.08, 'Bitcoin'))
    end

    it 'Bitcoin to USD' do
      expect(ten_bitco.convert_to('USD')).to eq(DawandaMoney::Money.new(2361.70, 'USD'))
    end

    it 'USD to HRN' do
      expect(twenty_dollars.convert_to('HRN')).to eq(DawandaMoney::Money.new(526.00, 'HRN'))
    end

    it 'HRN to USD' do
      expect(hundred_hrn.convert_to('USD')).to eq(DawandaMoney::Money.new(3.80, 'USD'))
    end

    it 'EUR to HRN' do
      expect(fifty_eur.convert_to('HRN')).to eq(DawandaMoney::Money.new(1459.65, 'HRN'))
    end

    it 'HRN to EUR' do
      expect(hundred_hrn.convert_to('EUR')).to eq(DawandaMoney::Money.new(3.43, 'EUR'))
    end

    it 'HRN to RUR' do
      expect(hundred_hrn.convert_to('RUR')).to eq(DawandaMoney::Money.new(256.04, 'RUR'))
    end

    it 'Bitcoin to HRN' do
      expect(ten_bitco.convert_to('HRN')).to eq(DawandaMoney::Money.new(62112.78, 'HRN'))
    end
  end

  describe 'arithmetics' do
    before :each do
      DawandaMoney::Money.conversion_rates('EUR', {'USD' => 1.11, 'Bitcoin' => 0.0047})
    end

    it 'plus with fixnum' do
      expect(fifty_eur + 20).to eq(DawandaMoney::Money.new(70, 'EUR'))
    end

    it 'plus with Money' do
      expect(fifty_eur + twenty_dollars).to eq(DawandaMoney::Money.new(68.02, 'EUR'))
    end

    it 'minus with fixnum' do
      expect(fifty_eur - 15).to eq(DawandaMoney::Money.new(35, 'EUR'))
    end

    it 'minus with Money' do
      expect(fifty_eur - twenty_dollars).to eq(DawandaMoney::Money.new(31.98, 'EUR'))
    end

    it 'devide with fixnum' do
      expect(fifty_eur / 2).to eq(DawandaMoney::Money.new(25, 'EUR'))
    end

    it 'devide with Money' do
      expect(fifty_eur / twenty_dollars).to eq(DawandaMoney::Money.new(2.774694783573807, 'EUR'))
    end

    it 'multi with fixnum' do
      expect(twenty_dollars * 3).to eq(DawandaMoney::Money.new(60, 'USD'))
    end

    it 'multi with Money' do
      expect(twenty_dollars * fifty_eur).to eq(DawandaMoney::Money.new(1110.00, 'USD'))
    end
  end

  describe 'comparisons' do
    before :each do
      DawandaMoney::Money.conversion_rates('EUR', {'USD' => 1.11, 'Bitcoin' => 0.0047})
    end

    it 'equal true' do
      expect(twenty_dollars == DawandaMoney::Money.new(20.00, 'USD')).to be_truthy
    end

    it 'equal true in different currencies' do
      twenty_dollars_in_eur = twenty_dollars.convert_to('EUR')
      expect(twenty_dollars == twenty_dollars_in_eur).to be_truthy
    end

    it 'equal false' do
      expect(twenty_dollars == DawandaMoney::Money.new(25.00, 'USD')).to be_falsy
    end

    it 'not equal true' do
      expect(twenty_dollars != DawandaMoney::Money.new(20.00, 'USD')).to be_falsy
    end

    it 'not equal false' do
      expect(twenty_dollars != DawandaMoney::Money.new(25.00, 'USD')).to be_truthy
    end

    it 'more true' do
      expect(twenty_dollars > DawandaMoney::Money.new(10.00, 'EUR')).to be_truthy
    end

    it 'more false' do
      expect(twenty_dollars > DawandaMoney::Money.new(20.00, 'EUR')).to be_falsy
    end

    it 'more or equal true' do
      expect(twenty_dollars >= DawandaMoney::Money.new(10.00, 'EUR')).to be_truthy
    end

    it 'more or equal false' do
      expect(twenty_dollars >= DawandaMoney::Money.new(20.00, 'EUR')).to be_falsy
    end

    it 'less true' do
      expect(twenty_dollars < DawandaMoney::Money.new(20.00, 'EUR')).to be_truthy
    end

    it 'less false' do
      expect(twenty_dollars < DawandaMoney::Money.new(10.00, 'EUR')).to be_falsy
    end

    it 'less or equal true' do
      expect(twenty_dollars <= DawandaMoney::Money.new(20.00, 'EUR')).to be_truthy
    end

    it 'less or equal false' do
      expect(twenty_dollars <= DawandaMoney::Money.new(10.00, 'EUR')).to be_falsy
    end
  end
end
