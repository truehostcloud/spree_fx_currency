module Spree
  module ProductDecorator
    def self.prepended(base)
      base.after_save :update_prices
    end

    def update_prices
      stores.each do |store|
        default_currency = store.default_currency
        supported_currencies = store.supported_currencies.split(',')
                                    .reject { |c| default_currency.to_s == c.upcase }
        supported_currencies.map do |c|
          fx = Spree::FxRate.where(from_currency: default_currency, to_currency: c.upcase).first
          fx.update_prices_for_product(self)
        end
      end
    end
  end
end

Spree::Product.prepend(Spree::ProductDecorator)
