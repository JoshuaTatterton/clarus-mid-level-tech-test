class AddStockQuantityConstraint < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute "ALTER TABLE stocks ADD CONSTRAINT quantity_cannot_be_negative CHECK(quantity >= 0);"
    end
  end

  def down
    safety_assured do
      execute "ALTER TABLE stocks DROP CONSTRAINT quantity_cannot_be_negative;"
    end
  end
end
