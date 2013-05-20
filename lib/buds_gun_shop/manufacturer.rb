require 'active_model'
require 'mechanize'

module BudsGunShop
  class Manufacturer
    include ActiveModel::Validations

    attr_accessor :name, :id

    validates :name, presence: true
    validates :id,   presence: true

    def initialize(attrs={})
      attrs.each{|a,v| send(a.to_s+'=', v) }
      self
    end

    def self.all
      page = Celluloid::Actor[:session_pool].get("#{CATALOG_ROOT}/ajax/manufacturers_ajax.php")
      page.search('form select option').map do |e|
        self.new(:id => e.attr(:value), :name => e.text.sub(/\(\d*\)\z/, '').strip)
      end
    end

  end
end
