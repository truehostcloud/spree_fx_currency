class CreateSpreeFxRates < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_fx_rates, if_not_exists: true do |t|
      t.string :from_currency
      t.string :to_currency
      t.float :rate, default: 1.00

      t.timestamps null: false
    end
  end
end
