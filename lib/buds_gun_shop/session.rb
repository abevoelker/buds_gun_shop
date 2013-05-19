require 'celluloid'

module BudsGunShop
  class Session
    include Celluloid

    def initialize
      @agent = Mechanize.new
    end

    def get(*args, &block)
      @agent.get(*args, &block)
    end
  end
end
