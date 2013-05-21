require 'buds_gun_shop/version'
require 'buds_gun_shop/rate_limiter'
require 'buds_gun_shop/session'
require 'buds_gun_shop/product'
require 'buds_gun_shop/manufacturer'
require 'buds_gun_shop/category'

module BudsGunShop
  SITE_ROOT    = 'http://www.budsgunshop.com'
  CATALOG_ROOT = "#{SITE_ROOT}/catalog"
end
