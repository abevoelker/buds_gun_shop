require File.dirname(__FILE__) + '/unit_helper'

describe BudsGunShop::Agent do

  before do
    rate_limit = Celluloid::RateLimiter.new(100, 1)
    @agent = BudsGunShop::Agent.new(rate_limit)
  end

  describe 'fetching all manufacturers' do

    before do
      VCR.use_cassette('manufacturers all') do
        @manufacturers = @agent.all_manufacturers
      end
    end

    it "should create valid manufacturers" do
      @manufacturers.each do |m|
        expect(m).to be_valid
      end
    end

  end

end
