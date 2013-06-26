require File.dirname(__FILE__) + '/unit_helper'

describe BudsGunShop::Category do

  before do
    rate_limit = Celluloid::RateLimiter.new(100, 1)
    Celluloid::Actor[:buds_gun_shop_session] = BudsGunShop::Session.new(rate_limit)
  end

  describe 'new' do

    describe 'built without any values' do

      before do
        @category = BudsGunShop::Category.new
      end

      it "should not be valid" do
        expect(@category).not_to be_valid
      end

    end

    describe 'built with just name' do

      before do
        @category = BudsGunShop::Category.new(name: 'Foo')
      end

      it "should not be valid" do
        expect(@category).not_to be_valid
      end

    end

    describe 'built with just id' do

      before do
        @category = BudsGunShop::Category.new(id: '123')
      end

      it "should be valid" do
        expect(@category).to be_valid
      end

    end

    describe 'built with name and id' do

      before do
        @category = BudsGunShop::Category.new(name: 'Foo', id: '123')
      end

      it "should be valid" do
        expect(@category).to be_valid
      end

    end

  end

  describe 'find' do

    describe 'finding a valid category with children' do
      before do
        VCR.use_cassette('categories_all') do
          @category = BudsGunShop::Category.find('21_1171')
        end
      end

      it "should return exactly one category" do
        expect(@category).to be_a(BudsGunShop::Category)
        expect(@category.id).to eq('21_1171')
        expect(@category.name).to eq('1911s')
      end
    end

    describe 'finding a valid category with no children' do
      before do
        VCR.use_cassette('category_rifles') do
          @category = BudsGunShop::Category.find('36_1037')
        end
      end

      it "should return exactly one category" do
        expect(@category).to be_a(BudsGunShop::Category)
        expect(@category.id).to eq('36_1037')
        expect(@category.name).to eq('Adcor Defense')
      end
    end

    describe 'finding an invalid category' do
      before do
        VCR.use_cassette('categories_all') do
          @category = BudsGunShop::Category.find('asdfasdfafsd')
        end
      end

      it "should be nil" do
        expect(@category).to be_nil
      end
    end

  end

  describe 'all' do

    describe 'fetching all categories' do

      before do
        VCR.use_cassette('categories_all') do
          @categories = BudsGunShop::Category.all
        end
      end

      it "should create valid categories" do
        @categories.each do |c|
          expect(c).to be_valid
        end
      end

      it "should return a list of all root categories" do
        expect(@categories.size).to eq(34)
      end

    end

    describe 'fetching all flattened categories' do

      before do
        VCR.use_cassette('categories_all') do
          @categories = BudsGunShop::Category.all_flattened
        end
      end

      it "should create valid categories" do
        @categories.each do |c|
          expect(c).to be_valid
        end
      end

      it "should return a list of all root categories" do
        expect(@categories.size).to eq(855)
      end

    end

  end

  describe 'products' do

    describe 'a category with no products' do

      before do
        VCR.use_cassette('category_alexander_arms_accessories_products') do
          @category = BudsGunShop::Category.new(id: "36_42_102")
          @products = @category.products
        end
      end

      it "should return an empty array" do
        expect(@products).to eq([])
      end

    end

    describe 'a category with one page of products' do

      before do
        VCR.use_cassette('category_adcor_defense_products') do
          @category = BudsGunShop::Category.new(id: "36_1037")
          @products = @category.products
        end
      end

      it "should only load the products on first page" do
        expect(@products.size).to eq(7)
      end

    end

    describe 'a category with 494 products (10 pages)' do

      before do
        VCR.use_cassette('category_1911s_products') do
          @category = BudsGunShop::Category.new(id: "21_1171")
          @products = @category.products
        end
      end

      it "should load all 494 products" do
        expect(@products.size).to eq(494)
      end

    end

  end

end
