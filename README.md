buds_gun_shop
=============
[![Build Status](https://travis-ci.org/abevoelker/buds_gun_shop.png?branch=master)](https://travis-ci.org/abevoelker/buds_gun_shop)

Basic API for accessing http://www.budsgunshop.com

## Examples

```ruby
require 'buds_gun_shop'
rate_limit = BudsGunShop::RateLimiter.new(10, 1)
Celluloid::Actor[:session_pool] = BudsGunShop::Session.pool(args: [rate_limit])

categories = BudsGunShop::Category.all
rifles = BudsGunShop::Category.find(36)
manufacturers = BudsGunShop::Manufacturer.all
nugget = BudsGunShop::Product.find(411540200)
products = categories.map(&:products).flatten
```
