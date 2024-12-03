class AddColumnsToAdminUser < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_users, :role, :integer, null: false, default: 1 # 0: admin, 1: user
    add_column :admin_users, :wallet, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
