require 'virtus'
require 'active_model'
require 'mechanize'

module BudsGunShop
  class Manufacturer
    include Virtus
    include ActiveModel::Validations

    attribute :id,   String
    attribute :name, String

    validates :id,   presence: true
    validates :name, presence: true

    def self.all
      page = Celluloid::Actor[:session_pool].get("#{CATALOG_ROOT}/ajax/manufacturers_ajax.php")
      page.search('form select option').map do |e|
        self.new(:id => e.attr(:value), :name => e.text.sub(/\(\d*\)\z/, '').strip)
      end
    end

  end
end
