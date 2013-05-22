require File.dirname(__FILE__) + '/unit_helper'

class ProductSpec < MiniTest::Spec

  describe 'Product' do

    before do
      rate_limit = BudsGunShop::RateLimiter.new(100, 1)
      Celluloid::Actor[:session_pool] = BudsGunShop::Session.pool(args: [rate_limit])
    end

    describe 'built without any values' do

      before do
        @product = BudsGunShop::Product.new
      end

      it "should not be valid" do
        @product.wont_be :valid?
      end

    end

    describe 'built with just item_no' do

      before do
        @product = BudsGunShop::Product.new(:item_no => 'foo')
      end

      it "should be valid" do
        @product.must_be :valid?
      end

    end

    describe 'non-existent' do

      before do
        VCR.use_cassette('invalid_product') do
          @product = BudsGunShop::Product.find(454564656)
        end
      end

      it "should be nil" do
        @product.must_be :nil?
      end

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

    describe 'with specifications section' do
      before do
        VCR.use_cassette('FS-2000') do
          @product = BudsGunShop::Product.find(4461)
        end
      end

      it "should set specifications attribute" do
        @product.specifications.size.must_equal 14
        @product.specifications['Capacity'].must_equal '30 + 1'
        @product.specifications['Caliber'].must_equal '223 Remington/5.56 NATO'
      end
    end

    describe 'with extra "Specifications" word above table' do
      before do
        VCR.use_cassette('adcor_bear') do
          @product = BudsGunShop::Product.find(411552563)
        end
      end

      it "should set specifications attribute properly" do
        @product.specifications.size.must_equal 14
        @product.specifications['Capacity'].must_equal 'Not Available'
        @product.specifications['Caliber'].must_equal 'Not Available'
      end
    end

    describe 'without specifications section' do

      before do
        VCR.use_cassette('5.11 socks') do
          @product = BudsGunShop::Product.find(311009027)
        end
      end

      it "should set specifications attribute to nil" do
        @product.specifications.must_be :nil?
      end
    end

    describe 'init from URL' do

      before do
        @product = BudsGunShop::Product.init_from_url("http://www.budsgunshop.com/catalog/product_info.php/cPath" +
                                                      "/36_1037/products_id/76044/Adcor+Defense+B.E.A.R.+Semi-Au" +
                                                      "tomatic+223+Rem5.56+NATO")
      end

      it "should parse correct product ID from a product URL" do
        @product.item_no.must_equal "76044"
      end
    end

  end

end
