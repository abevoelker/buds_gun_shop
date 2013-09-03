require 'virtus'
require 'active_model'
require 'money'

module BudsGunShop
  class Product
    include Virtus
    include ActiveModel::Validations

    attribute :id,             String
    attribute :name,           String
    attribute :mfg_code,       String
    attribute :upc,            String
    attribute :manufacturer,   String
    attribute :condition,      String
    attribute :in_stock,       Boolean, default: false
    attribute :price,          Money
    attribute :description,    String
    attribute :specifications, Hash[String => String]

    validates :id, presence: true

    def new?
      condition == "Factory New"
    end
  end
end
