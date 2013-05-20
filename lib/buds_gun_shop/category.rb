require 'active_model'
require 'mechanize'
require 'andand'

module BudsGunShop
  class Category
    include ActiveModel::Validations

    attr_accessor :name, :id, :parent, :children

    validates :name, presence: true
    validates :id,   presence: true

    def initialize(attrs={})
      attrs.each{|a,v| send(a.to_s+'=', v) }
      self.children ||= []
      self
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
      page = Celluloid::Actor[:session_pool].get("http://www.budsgunshop.com/catalog/ajax/categories.php?cID=#{id}")
      init_from_xml(page)
    end

    def self.all
      root = Celluloid::Actor[:session_pool].get('http://www.budsgunshop.com/catalog/ajax/categories.php')
      init_from_xml(root)
    end

  end
end
