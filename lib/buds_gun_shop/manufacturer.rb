require 'virtus'
require 'active_model'

module BudsGunShop
  class Manufacturer
    include Virtus
    include ActiveModel::Validations

    attribute :id,   String
    attribute :name, String

    validates :id,   presence: true
    validates :name, presence: true
  end
end
