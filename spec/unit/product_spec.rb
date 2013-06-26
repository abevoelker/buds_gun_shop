require File.dirname(__FILE__) + '/unit_helper'

describe BudsGunShop::Product do

  before do
    rate_limit = Celluloid::RateLimiter.new(100, 1)
    Celluloid::Actor[:buds_gun_shop_session] = BudsGunShop::Session.new(rate_limit)
  end

  describe 'built without any values' do

    before do
      @product = BudsGunShop::Product.new
    end

    it "should not be valid" do
      expect(@product).not_to be_valid
    end

  end

  describe 'built with just id' do

    before do
      @product = BudsGunShop::Product.new(id: 'foo')
    end

    it "should be valid" do
      expect(@product).to be_valid
    end

  end

  describe 'non-existent' do

    before do
      VCR.use_cassette('product invalid') do
        @product = BudsGunShop::Product.find(454564656)
      end
    end

    it "should be nil" do
      expect(@product).to be_nil
    end

  end

  describe 'in-stock' do

    before do
      VCR.use_cassette('product Ruger 10-22') do
        @product = BudsGunShop::Product.find(70280)
      end
    end

    it "should show as in stock" do
      expect(@product).to be_in_stock
    end

    it "should have a price" do
      expect(@product.price).to eq(Money.parse("$266.77"))
    end

  end

  describe 'condition: new' do

    before do
      VCR.use_cassette('product Ruger 10-22') do
        @product = BudsGunShop::Product.find(70280)
      end
    end

    it "should expose correct condition value" do
      expect(@product.condition).to eq("Factory New")
    end

    it "should return true for new?" do
      expect(@product).to be_new
    end

  end

  describe 'with UPC' do

    before do
      VCR.use_cassette('product Ruger 10-22') do
        @product = BudsGunShop::Product.find(70280)
      end
    end

    it "should expose correct UPC value" do
      expect(@product.upc).to eq("736676011032")
    end

  end

  describe 'with manufacturer' do

    before do
      VCR.use_cassette('product Ruger 10-22') do
        @product = BudsGunShop::Product.find(70280)
      end
    end

    it "should expose correct manufacturer value" do
      expect(@product.manufacturer).to eq("Sturm, Ruger, & Co., Inc.")
    end

  end

  describe 'out of stock' do

    before do
      VCR.use_cassette('product FS-2000') do
        @product = BudsGunShop::Product.find(4461)
      end
    end

    it "should show as out of stock" do
      expect(@product).not_to be_in_stock
    end

  end

  describe 'with specifications section' do
    before do
      VCR.use_cassette('product FS-2000') do
        @product = BudsGunShop::Product.find(4461)
      end
    end

    it "should set specifications attribute" do
      expect(@product.specifications.size).to eq(14)
      expect(@product.specifications['Capacity']).to eq('30 + 1')
      expect(@product.specifications['Caliber']).to eq('223 Remington/5.56 NATO')
    end
  end

  describe 'with extra "Specifications" word above table' do
    before do
      VCR.use_cassette('product adcor bear') do
        @product = BudsGunShop::Product.find(411552563)
      end
    end

    it "should set specifications attribute properly" do
      expect(@product.specifications.size).to eq(14)
      expect(@product.specifications['Capacity']).to eq('Not Available')
      expect(@product.specifications['Caliber']).to eq('Not Available')
    end
  end

  describe 'without specifications section' do

    before do
      VCR.use_cassette('product 5.11 socks') do
        @product = BudsGunShop::Product.find(311009027)
      end
    end

    it "should set specifications attribute to nil" do
      expect(@product.specifications).to be_nil
    end
  end

  describe 'init from URL' do

    before do
      @product = BudsGunShop::Product.init_from_url("http://www.budsgunshop.com/catalog/product_info.php/cPath" +
                                                    "/36_1037/products_id/76044/Adcor+Defense+B.E.A.R.+Semi-Au" +
                                                    "tomatic+223+Rem5.56+NATO")
    end

    it "should parse correct product ID from a product URL" do
      expect(@product.id).to eq("76044")
    end

    it "should not greedy match URLs" do
      @product = BudsGunShop::Product.init_from_url("http://www.budsgunshop.com/catalog/product_info.php/cPath" +
                                                    "/884/products_id/411550457/Overstock+Guns/LEGACY%20PUMA%2" +
                                                    "022LR%204.63/quot;%20REVOLVER%20WOOD%20GRIPS/")
      expect(@product.id).to eq("411550457")
    end
  end

  describe 'with description and specifications outside white background' do

    before do
      VCR.use_cassette('product FN SCAR') do
        @product = BudsGunShop::Product.find(62606)
      end
    end

    it "should parse description properly" do
      expect(@product.description).to match("FAMILY:SCAR Series")
      expect(@product.description).to match("ADDL INFO:Ambidextrous Controls")
    end

    it "should parse specifications properly" do
      expect(@product.specifications.size).to eq(14)
      expect(@product.specifications['Finish']).to eq('Flat Dark Earth/Black Barrel')
      expect(@product.specifications['Caliber']).to eq('308 Winchester')
      expect(@product.specifications['Weight']).to eq('8 lbs')
    end

  end

  describe 'with all product info inside the white background' do

    before do
      VCR.use_cassette('product puma revolver') do
        @product = BudsGunShop::Product.find(411550457)
      end
    end

    it "should parse description properly" do
      expect(@product.description).to match("Legacy Puma M-1873 .22 CALIBER REVOLVER, PCR187322W")
      expect(@product.description).to match("With the frame size and weight of a Single Action Army revolver")
    end

    it "should parse specifications properly" do
      expect(@product.specifications.size).to eq(9)
      expect(@product.specifications['Type']).to eq('Revolver')
      expect(@product.specifications['Capacity']).to eq('6')
    end

  end

end
