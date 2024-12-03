class AddRepayAmountToLoan < ActiveRecord::Migration[7.0]
  def change
    add_column :loans, :repaid_amount, :decimal, default: 0.0
  end
end
