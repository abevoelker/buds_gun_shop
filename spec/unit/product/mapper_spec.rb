require File.dirname(__FILE__) + '/../unit_helper'

describe BudsGunShop::Product::Mapper do
  describe 'init from URL' do
    it "should parse correct product ID from a product URL" do
      @product = BudsGunShop::Product::Mapper.init_from_url("http://www.budsgunshop.com/catalog/product_info.php/cPath" +
                                                            "/36_1037/products_id/76044/Adcor+Defense+B.E.A.R.+Semi-Au" +
                                                            "tomatic+223+Rem5.56+NATO")
      expect(@product.id).to eq("76044")
    end

    it "should not greedy match URLs" do
      @product = BudsGunShop::Product::Mapper.init_from_url("http://www.budsgunshop.com/catalog/product_info.php/cPath" +
                                                            "/884/products_id/411550457/Overstock+Guns/LEGACY%20PUMA%2" +
                                                            "022LR%204.63/quot;%20REVOLVER%20WOOD%20GRIPS/")
      expect(@product.id).to eq("411550457")
    end
  end

end
