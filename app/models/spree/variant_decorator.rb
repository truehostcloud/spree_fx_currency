module Spree
  module VariantDecorator
    def self.prepended(base)
      base.after_save :update_prices
    end

    def update_prices
      Spree::FxRate.all.find_each { |r| r.update_prices_for_variant(self) }
    end
  end
end

Spree::Variant.prepend(Spree::VariantDecorator)
