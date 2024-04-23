class AddOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.integer :status, default: 0
      t.belongs_to :stock, null: false, foreign_key: true

      t.timestamps
    end

    add_index :orders, :status
  end
end
