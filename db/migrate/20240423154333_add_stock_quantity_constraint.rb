class AddStockQuantityConstraint < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :stocks, "quantity >= 0", name: "quantity_cannot_be_negative", validate: false
  end
end
