require 'celluloid/autostart'

module BudsGunShop
  class Session
    include Celluloid

    def initialize(rate_limiter)
      @rate_limiter, @agent = rate_limiter, Mechanize.new
    end

    def get(*args, &blk)
      @rate_limiter.limit{@agent.get(*args, &blk)}.value
    end
  end
end
