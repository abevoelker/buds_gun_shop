# -*- encoding: utf-8 -*-
require 'andand'

module BudsGunShop
  class Product
    class Mapper
      def self.load(page)
        return if page.at("td:contains('Product not found!')")

        main_table = page.at('#mainmain div table table table')

        Product.new.tap do |p|
          p.name = main_table.at('//h1').text.strip
          p.in_stock = !!page.at("#A2C") #!main_table.at("span:contains('OUT OF STOCK')")

          # white main product area - not always nicely separated
          header_selector = "table[style~='background-color:#FFFFFF;']"
          header_area = page.at(header_selector)

          # description
          desc_div_selector = "div[style~='padding-left:24px; padding-right:24px;']"
          p.description = page.search(desc_div_selector).andand.
                          map{|n| n.text.gsub(/(Â|­| )/, "").gsub("\r\n", "\n").strip}.andand.
                          join("\n")

          # price
          price_elem = page.at("span:contains('Retail Price')")
          if price_elem
            p.price = Money.parse(price_elem.parent.at('strong').text)
          end

          # specifications
          spec_rows = page.at("td > strong:contains('Specifications')").andand.parent.
            andand.parent.andand.parent.andand.children.andand[1..-1]
          p.specifications = spec_rows.andand.reduce({}){|a,h| a[h.search('td')[0].text.strip] = h.search('td')[1].text.strip; a }

          # other attributes
          attrs = ["Model:", "UPC:", "Bud's Item Number:", "MFG:", "Condition:"].map do |txt|
            page.at("span:contains(\"#{txt}\")").andand.next_element.andand.text.andand.strip
          end
          [:mfg_code=, :upc=, :id=, :manufacturer=, :condition=].zip(attrs).each do |setter, val|
            p.send(setter, val)
          end
        end
      end

      def self.init_from_url(url)
        Product.new(id: url.match(/\/products_id\/(\S+?)\//).captures[0])
      end

      def self.all_from_index_page(page)
        links = page.search('.productListing-productname a').map{|a| a.attr('href')}
        links.map{|l| init_from_url(l)}
      end
    end
  end
end
