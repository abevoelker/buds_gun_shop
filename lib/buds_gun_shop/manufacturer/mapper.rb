module BudsGunShop
  class Manufacturer
    class Mapper
      def self.load(page)
        page.search('form select option').map do |e|
          Manufacturer.new(id: e.attr(:value), name: e.text.sub(/\(\d*\)\z/, '').strip)
        end
      end
    end
  end
end
