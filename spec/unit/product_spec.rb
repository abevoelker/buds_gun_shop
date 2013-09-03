require File.dirname(__FILE__) + '/unit_helper'

describe BudsGunShop::Product do

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

end
