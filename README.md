buds_gun_shop
=============
[![Build Status](https://travis-ci.org/abevoelker/buds_gun_shop.png?branch=master)](https://travis-ci.org/abevoelker/buds_gun_shop)

Basic API for accessing http://www.budsgunshop.com

## Examples

```ruby
require 'buds_gun_shop'
rate_limit = Celluloid::RateLimiter.new(10, 1)
Celluloid::Actor[:buds_gun_shop_session] = BudsGunShop::Session.new(rate_limit)

root_categories = BudsGunShop::Category.all
all_categories = BudsGunShop::Category.all_flattened
rifles = BudsGunShop::Category.find(36)

nugget = BudsGunShop::Product.find(411540200)
all_products = all_categories.map(&:products).flatten

manufacturers = BudsGunShop::Manufacturer.all
```
