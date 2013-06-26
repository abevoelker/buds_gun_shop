require File.dirname(__FILE__) + '/unit_helper'

describe BudsGunShop::Manufacturer do

  before do
    rate_limit = Celluloid::RateLimiter.new(100, 1)
    Celluloid::Actor[:buds_gun_shop_session] = BudsGunShop::Session.new(rate_limit)
  end

  describe 'built without any values' do

    before do
      @manufacturer = BudsGunShop::Manufacturer.new
    end

    it "should not be valid" do
      expect(@manufacturer).not_to be_valid
    end

  end

  describe 'built with just name' do

    before do
      @manufacturer = BudsGunShop::Manufacturer.new(name: 'Foo')
    end

    it "should not be valid" do
      expect(@manufacturer).not_to be_valid
    end

  end

  describe 'built with just id' do

    before do
      @manufacturer = BudsGunShop::Manufacturer.new(id: '123')
    end

    it "should not be valid" do
      expect(@manufacturer).not_to be_valid
    end

  end

  describe 'built with name and id' do

    before do
      @manufacturer = BudsGunShop::Manufacturer.new(name: 'Foo', id: '123')
    end

    it "should be valid" do
      expect(@manufacturer).to be_valid
    end

  end

  describe 'fetching all manufacturers' do

    before do
      VCR.use_cassette('manufacturers all') do
        @manufacturers = BudsGunShop::Manufacturer.all
      end
    end

    it "should create valid manufacturers" do
      @manufacturers.each do |m|
        expect(m).to be_valid
      end
    end

  end

end
