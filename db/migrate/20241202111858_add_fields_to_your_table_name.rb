class AddFieldsToYourTableName < ActiveRecord::Migration[7.0]
  def change
    add_reference :loans, :user, null: false, foreign_key: true
    add_column :loans, :amount, :decimal
    add_column :loans, :interest_rate, :decimal
    add_column :loans, :total_interest, :decimal
    add_column :loans, :total_amount, :decimal
    add_column :loans, :state, :string
    add_column :loans, :adjustments, :text
  end
end
