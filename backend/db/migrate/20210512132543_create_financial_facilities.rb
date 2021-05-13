class CreateFinancialFacilities < ActiveRecord::Migration[6.1]
  def change
    create_table :financial_facilities do |t|
      t.string :name

      t.timestamps
    end
  end
end
