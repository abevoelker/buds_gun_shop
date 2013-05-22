require 'celluloid/autostart'

module BudsGunShop
  class RateLimiter
    include Celluloid

    def initialize(actions_per, seconds)
      @bucket, @nice = actions_per, seconds
    end

    def limit(&blk)
      wait :bucket_increment unless @bucket > 0
      @bucket -= 1
      after(@nice) { @bucket += 1; signal :bucket_increment }
    end
  end
end
