require File.dirname(__FILE__) + '/unit_helper'

class CategorySpec < MiniTest::Spec

  describe 'Category' do

    before do
      rate_limit = BudsGunShop::RateLimiter.new(100, 1)
      Celluloid::Actor[:session_pool] = BudsGunShop::Session.pool(args: [rate_limit])
    end

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

      describe 'without children' do

        it "should return an array just including itself for to_a" do
          @category.to_a.must_equal [@category]
        end

      end

      describe 'with children' do

        before do
          @child1   = BudsGunShop::Category.new(:name => 'child1', :id => '123_1')
          @child2   = BudsGunShop::Category.new(:name => 'child2', :id => '123_2')
          @category.children << @child1
          @category.children << @child2
        end

        it "should add children to children reader" do
          @category.children.must_equal [@child1, @child2]
        end

      end

    end

    describe 'fetching all categories' do

      before do
        VCR.use_cassette('categories_all') do
          @categories = BudsGunShop::Category.all
        end
      end

      it "should create valid categories" do
        @categories.each{|c| c.must_be :valid?}
      end

      it "should return a flattened list of all categories" do
        @categories.size.must_equal 855
        @categories.reject{|c| c.parent.nil?}.must_be_empty
      end

    end

    describe 'with one page of products' do

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

    describe 'with 494 products (10 pages)' do

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
