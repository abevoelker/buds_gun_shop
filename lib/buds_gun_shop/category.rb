# -*- encoding: utf-8 -*-

require 'active_model'
require 'mechanize'
require 'andand'

module BudsGunShop
  class Category
    include ActiveModel::Validations

    attr_accessor :name, :id, :parent, :children

    validates :id,   presence: true

    def initialize(attrs={})
      attrs.each{|a,v| send(a.to_s+'=', v) }
      self.children ||= []
      self
    end

    def to_a
      [self] + children.map(&:to_a)
    end

    def products
      page = Celluloid::Actor[:session_pool].get("#{CATALOG_ROOT}/index.php/cPath/#{id}")
      products = []
      begin
        next_pg = page.link_with(:text => "[Next >>]")
        products += BudsGunShop::Product.all_from_index_page(page)
        page = Celluloid::Actor[:session_pool].click(next_pg) if next_pg
      end while next_pg
      products
    end

    def self.init_from_xml(xml, parent=nil)
      xml.search('//category').map do |c|
        id, name, is_leaf = ['id', 'name', 'isleaf'].map{|n| c.at(n).andand.text }
        category = self.new(:name => name, :id => id, :parent => parent)
        category.children = find(id) unless is_leaf
        category
      end
    end

    def self.find(id)
      page = Celluloid::Actor[:session_pool].get("#{CATALOG_ROOT}/ajax/categories.php?cID=#{id}")
      init_from_xml(page)
    end

    def self.all
      root = Celluloid::Actor[:session_pool].get("#{CATALOG_ROOT}/ajax/categories.php")
      init_from_xml(root).map(&:to_a).flatten
    end

  end
end
