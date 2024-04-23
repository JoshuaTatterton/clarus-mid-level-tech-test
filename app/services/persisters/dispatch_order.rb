module Persisters
  class DispatchOrder
    def initialize(order:)
      @order = order
    end

    def call
      @order.transaction do
        validate_order_is_dispatchable!
        validate_stock_available!

        decrement_stock_quantity!
        update_order_status!
      end
    end

    private

    def validate_order_is_dispatchable!
      return true if @order.received?

      @order.errors.add(:status, :already_dispatched)
      raise ActiveRecord::Rollback
    end

    def validate_stock_available!
      return true if @order.stock.quantity > 0

      @order.errors.add(:stock, :quantity_unavailable)
      raise ActiveRecord::Rollback
    end

    DECREMENT_STOCK_QUERY = <<-SQL
      UPDATE stocks
      SET quantity = quantity - 1
      WHERE id = %{stock_id}
      RETURNING id
    SQL

    def decrement_stock_quantity!
      query = DECREMENT_STOCK_QUERY % { stock_id: @order.stock_id }
      result = { "id" => nil }

      begin
        result = Order.connection.select_one(query)
      rescue
      end

      return true if result && result["id"] == @order.stock_id

      @order.errors.add(:stock, :decrement_stock_failed)
      raise ActiveRecord::Rollback
    end

    def update_order_status!
      return true if @order.update(status: :dispatched)

      raise ActiveRecord::Rollback
    end
  end
end
