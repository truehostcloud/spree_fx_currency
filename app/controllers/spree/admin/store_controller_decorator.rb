module Spree
  module Admin
    module StoresControllerDecorator
      def self.prepended(base)
        base.after_action :create_fx_rates_for_currencies, only: %i[create update]
      end

      def create_fx_rates_for_currencies
        Spree::FxRate.create_supported_currencies(current_store) if Spree::FxRate.none? || @store.supported_currencies_previously_changed?
      end
    end
  end
end

Spree::Admin::StoresController.prepend(Spree::Admin::StoresControllerDecorator)
