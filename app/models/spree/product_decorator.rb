module Spree
  module ProductDecorator
    def self.prepended(base)
      base.after_save :update_prices
    end

    def update_prices
      Spree::FxRate.all.find_each { |r| r.update_prices_for_product(self) }
    end
  end
end

Spree::Product.prepend(Spree::ProductDecorator)
