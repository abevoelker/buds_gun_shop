require File.dirname(__FILE__) + '/unit_helper'

class CategorySpec < MiniTest::Spec

  describe 'Category' do

    before do
      rate_limit = BudsGunShop::RateLimiter.new(100, 1)
      Celluloid::Actor[:session_pool] = BudsGunShop::Session.pool(args: [rate_limit])
    end

    describe 'new' do

      describe 'built without any values' do

        before do
          @category = BudsGunShop::Category.new
        end

        it "should not be valid" do
          @category.wont_be :valid?
        end

      end

      describe 'built with just name' do

        before do
          @category = BudsGunShop::Category.new(:name => 'Foo')
        end

        it "should not be valid" do
          @category.wont_be :valid?
        end

      end

      describe 'built with just id' do

        before do
          @category = BudsGunShop::Category.new(:id => '123')
        end

        it "should be valid" do
          @category.must_be :valid?
        end

      end

      describe 'built with name and id' do

        before do
          @category = BudsGunShop::Category.new(:name => 'Foo', :id => '123')
        end

        it "should be valid" do
          @category.must_be :valid?
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
          @category.class.must_equal BudsGunShop::Category
          @category.id.must_equal '21_1171'
          @category.name.must_equal '1911s'
        end
      end

      describe 'finding a valid category with no children' do
        before do
          VCR.use_cassette('category_rifles') do
            @category = BudsGunShop::Category.find('36_1037')
          end
        end

        it "should return exactly one category" do
          @category.class.must_equal BudsGunShop::Category
          @category.id.must_equal '36_1037'
          @category.name.must_equal 'Adcor Defense'
        end
      end

      describe 'finding an invalid category' do
        before do
          VCR.use_cassette('categories_all') do
            @category = BudsGunShop::Category.find('asdfasdfafsd')
          end
        end

        it "should be nil" do
          @category.must_be :nil?
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
          @categories.each{|c| c.must_be :valid?}
        end

        it "should return a list of all root categories" do
          @categories.size.must_equal 34
          @categories.reject{|c| c.parent.nil?}.must_be_empty
        end

      end

      describe 'fetching all flattened categories' do

        before do
          VCR.use_cassette('categories_all') do
            @categories = BudsGunShop::Category.all_flattened
          end
        end

        it "should create valid categories" do
          @categories.each{|c| c.must_be :valid?}
        end

        it "should return a list of all root categories" do
          @categories.size.must_equal 855
          @categories.reject{|c| c.parent.nil?}.must_be_empty
        end

      end

    end

    describe 'products' do

      describe 'a category with no products' do

        before do
          VCR.use_cassette('category_alexander_arms_accessories') do
            @category = BudsGunShop::Category.new(:id => "36_42_102")
            @products = @category.products
          end
        end

        it "should return an empty array" do
          @products.must_equal []
        end

      end

      describe 'a category with one page of products' do

        before do
          VCR.use_cassette('adcor_defense') do
            @category = BudsGunShop::Category.new(:id => "36_1037")
            @products = @category.products
          end
        end

        it "should only load the products on first page" do
          @products.size.must_equal 7
        end

      end

      describe 'a category with 494 products (10 pages)' do

        before do
          VCR.use_cassette('1911_category') do
            @category = BudsGunShop::Category.new(:id => "21_1171")
            @products = @category.products
          end
        end

        it "should load all 494 products" do
          @products.size.must_equal 494
        end

      end

    end

  end

end
