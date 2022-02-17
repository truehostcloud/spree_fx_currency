require 'fixer_client'

module Spree
  class FxRate < Spree::Base
    validates :from_currency, presence: true
    validates :to_currency, presence: true

    validates :rate, numericality: {
      greater_than_or_equal_to: 0
    }

    after_save :update_products_prices

    @store = nil

    def self.spree_currency
      @@store.default_currency
    end

    def self.supported_currencies
      @@store.supported_currencies.split(',')
             .reject { |c| spree_currency.to_s == c.upcase }
    rescue NoMethodError => _e
      []
    end

    def self.sync_currencies_from_store
      found_currencies = supported_currencies.map do |c|
        find_or_create_by(from_currency: spree_currency, to_currency: c.upcase).id
      end
      # Comment Out To Not Delete Other Currencies
      where.not(id: found_currencies).destroy_all
    end

    # Called when Store is updated
    def self.create_supported_currencies(store = nil)
      return unless table_exists?

      store ||= Spree::Store.default

      @@store = store

      sync_currencies_from_store
      fetch_fixer
    end

    def self.fetch_fixer
      request = FixerClient.new(spree_currency, all.pluck(:to_currency))
      request.fetch.each do |result|
        currency = result[:to]
        value = result[:val]
        m = find_by(to_currency: currency)
        m.try(:update, rate: value)
      end
      true
    end

    def fetch_fixer
      request = FixerClient.new(from_currency, [to_currency])
      result = request.fetch
      return false unless result

      result = result.first

      new_rate = result[:val]

      update(rate: new_rate)
    end

    # @todo: implement force option for only applying
    #        fx rate changes to blank prices
    def update_products_prices(store = nil)
      store ||= Spree::Store.default
      @@store ||= store

      Spree::Product.transaction do
        @@store.products.all.find_each { |p| update_prices_for_product(p) }
      end
    end

    def update_prices_for_product(product)
      product.variants_including_master.each do |variant|
        update_prices_for_variant(variant)
      end
    end

    def update_prices_for_variant(variant)
      from_price = variant.price_in(from_currency.upcase)

      return if from_price.new_record?

      new_price = variant.price_in(to_currency.upcase)
      new_price.amount = from_price.amount * rate
      new_price.save if new_price.changed?
    end
  end
end
