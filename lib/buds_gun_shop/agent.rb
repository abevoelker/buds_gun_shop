require 'celluloid/autostart'
require 'celluloid/rate_limit'
require 'mechanize'
require 'buds_gun_shop/manufacturer/mapper'
require 'buds_gun_shop/product/mapper'

module BudsGunShop
  class Agent
    include Celluloid
    include Celluloid::RateLimit

    rate_limit :get, :click, using: Proc.new{ @rate_limiter }

    def initialize(rate_limiter)
      @rate_limiter, @agent = rate_limiter, Mechanize.new
    end

    def get(*args, &blk)
      @agent.get(*args, &blk)
    end

    def click(*args, &blk)
      @agent.click(*args, &blk)
    end

    def manufacturer
      ManufacturerContext.new(Celluloid::Actor.current)
    end

    def product
      ProductContext.new(Celluloid::Actor.current)
    end
  end
end

module BudsGunShop
  class Agent
    class ManufacturerContext
      def initialize(agent)
        @agent = agent
      end

      def all
        page = @agent.get("#{CATALOG_ROOT}/ajax/manufacturers_ajax.php")
        Manufacturer::Mapper.load(page)
      end
    end
  end
end

module BudsGunShop
  class Agent
    class ProductContext
      def initialize(agent)
        @agent = agent
      end

      def find(id)
        page = @agent.get("#{CATALOG_ROOT}/product_info.php/products_id/#{id}")
        Product::Mapper.load(page)
      end
    end
  end
end
