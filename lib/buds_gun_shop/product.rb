require 'active_model'
require 'mechanize'
require 'andand'
require 'money'

module BudsGunShop
  class Product
    include ActiveModel::Validations

    attr_accessor :name, :mfg_code, :upc, :item_no, :manufacturer,
                  :condition, :in_stock, :price

    validates :item_no, presence: true

    def initialize(attrs={})
      attrs.each{|a,v| send(a.to_s+'=', v) }
      self
    end

    def reload
      agent = Mechanize.new
      page = agent.get("http://www.budsgunshop.com/catalog/product_info.php/products_id/#{item_no}")
      return if page.at("td:contains('Product not found!')")

      main_table = page.at('#mainmain div table table table')

      self.name = main_table.at('//h1').text.strip
      self.in_stock = !!page.at("#A2C") #!main_table.at("span:contains('OUT OF STOCK')")

      price_elem = page.at("span:contains('Retail Price')")
      if price_elem
        self.price = Money.parse(price_elem.parent.at('strong').text)
      end

      # assign other attributes
      attrs = ["Model:", "UPC:", "Bud's Item Number:", "MFG:", "Condition:"].map do |txt|
        page.at("span:contains(\"#{txt}\")").andand.next_element.andand.text.andand.strip
      end
      [:mfg_code=, :upc=, :item_no=, :manufacturer=, :condition=].zip(attrs).each do |setter, val|
        send(setter, val)
      end

      self
    end

    def new?
      condition == "Factory New"
    end

    def self.find(item_no)
      Product.new(item_no: item_no).reload
    end

  end
end
