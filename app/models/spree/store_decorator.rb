module Spree
  module StoreDecorator
    def self.prepended(base)
      base.after_save :create_fx_rates_for_currencies
    end

    def create_fx_rates_for_currencies
      Spree::FxRate.create_supported_currencies(self) if Spree::FxRate.none? || supported_currencies_previously_changed?
    end
  end
end

Spree::Store.prepend(Spree::StoreDecorator)
