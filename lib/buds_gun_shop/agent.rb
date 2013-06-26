require 'celluloid/autostart'
require 'celluloid/rate_limit'

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
  end
end
