class AddColumnLoanCreditedAtToLoans < ActiveRecord::Migration[7.0]
  def change
    add_column :loans, :loan_credited_at, :datetime
  end
end
