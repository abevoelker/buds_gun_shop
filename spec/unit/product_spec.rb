require File.dirname(__FILE__) + '/unit_helper'

class ProductSpec < MiniTest::Spec

  describe 'Product' do

    before do
      @product = BudsGunShop::Product.new(:item_no => 'foo')
    end

    it "should be valid" do
      @product.must_be :valid?
    end

    describe 'in-stock' do

      before do
        VCR.use_cassette('Ruger 10-22') do
          @product = BudsGunShop::Product.find(70280)
        end
      end

      it "should show as in stock" do
        @product.must_be :in_stock
      end

      it "should have a price" do
        @product.price.must_equal Money.parse("$266.77")
      end

      it "should have a price" do
        @product.price.must_equal Money.parse("$266.77")
      end

    end

    describe 'condition: new' do

      before do
        VCR.use_cassette('Ruger 10-22') do
          @product = BudsGunShop::Product.find(70280)
        end
      end

      it "should expose correct condition value" do
        @product.condition.must_equal "Factory New"
      end

      it "should return true for new?" do
        @product.must_be :new?
      end

    end

    describe 'with UPC' do

      before do
        VCR.use_cassette('Ruger 10-22') do
          @product = BudsGunShop::Product.find(70280)
        end
      end

      it "should expose correct UPC value" do
        @product.upc.must_equal "736676011032"
      end

    end

    describe 'with manufacturer' do

      before do
        VCR.use_cassette('Ruger 10-22') do
          @product = BudsGunShop::Product.find(70280)
        end
      end

      it "should expose correct manufacturer value" do
        @product.manufacturer.must_equal "Sturm, Ruger, & Co., Inc."
      end

    end

    describe 'out of stock' do

      before do
        VCR.use_cassette('FS-2000') do
          @product = BudsGunShop::Product.find(4461)
        end
      end

      it "should show as out of stock" do
        @product.wont_be :in_stock
      end

    end

  end

end
