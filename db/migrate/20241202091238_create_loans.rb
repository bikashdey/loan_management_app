class CreateLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :loans do |t|

      t.timestamps
    end
  end
end
