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
      return_val = block_given? ? Celluloid::Future.new(&blk) : :ok
      after(@nice) { @bucket += 1; signal :bucket_increment }
      return_val
    end
  end
end
