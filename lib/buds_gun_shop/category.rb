# -*- encoding: utf-8 -*-

require 'virtus'
require 'active_model'
require 'mechanize'
require 'andand'

module BudsGunShop
  class Category
    include Virtus
    include ActiveModel::Validations

    attribute :id,       String
    attribute :name,     String
    attribute :is_leaf,  Boolean
    attribute :children, Array[Category]
    attribute :loaded,   Boolean, default: false

    validates :id,   presence: true

    def initialize(*args, &blk)
      @is_leaf ||= false
      @children ||= []
      @loaded = @is_leaf || @children.any?
      super
    end

    def to_a
      [self] + children.map(&:to_a)
    end

    def products
      page = Celluloid::Actor[:buds_gun_shop_agent].get("#{CATALOG_ROOT}/index.php/cPath/#{id}")
      products = []
      begin
        next_pg = page.link_with(text: "[Next >>]")
        products += BudsGunShop::Product.all_from_index_page(page)
        page = Celluloid::Actor[:buds_gun_shop_agent].click(next_pg) if next_pg
      end while next_pg
      products
    end

    # lazy accessor
    def children
      if @is_leaf
        @children
      else
        @children = Category.all(@id)
      end
    end

    def load(force=false)
      return true if loaded && !force
      # re-find this category
      Category.find(@id)
      # hit lazy children accessor
      self.children
      @loaded = true
    end

    def reload
      load(true)
    end

    def self.init_from_xml(xml)
      id, name, is_leaf = ['id', 'name', 'isleaf'].map{|n| xml.at(n).andand.text }
      self.new(name: name, id: id, is_leaf: is_leaf)
    end

    def self.find_from_xml(xml, id)
      xml = xml.at("//category/id[text()='#{id}']/..")
      init_from_xml(xml) if xml
    end

    def self.all_from_xml(xml, parent=nil)
      xml.search('//category').map{|c| init_from_xml(c)}
    end

    def self.find(id)
      parent = id.to_s.split('_')[-2]
      page = get_categories(parent)
      find_from_xml(page, id)
    end

    def self.all(parent=nil)
      page = get_categories(parent)
      all_from_xml(page)
    end

    def self.all_flattened
      all.map(&:to_a).flatten
    end

    def self.get_categories(parent=nil)
      if parent
         Celluloid::Actor[:buds_gun_shop_agent].get("#{CATALOG_ROOT}/ajax/categories.php?cID=#{parent}")
       else
         Celluloid::Actor[:buds_gun_shop_agent].get("#{CATALOG_ROOT}/ajax/categories.php")
       end
    end
    private_class_method :get_categories

  end
end
