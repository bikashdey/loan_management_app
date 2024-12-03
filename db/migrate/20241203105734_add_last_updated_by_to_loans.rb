class AddLastUpdatedByToLoans < ActiveRecord::Migration[7.0]
  def change
    add_column  :loans, :last_updated_by, :string
  end
end
