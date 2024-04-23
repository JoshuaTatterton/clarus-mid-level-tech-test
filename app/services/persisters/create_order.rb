module Persisters
  class CreateOrder
    def initialize(order:, warehouse_id:, product_id:)
      @order = order
      @warehouse_id = warehouse_id
      @product_id = product_id
    end

    def call
      @order.transaction do
        @warehouse = find_warehouse!
        @product = find_product!

        validate_available_stock!

        stock = next_available_stock

        @order.update(stock: stock)
      end
    end

    private

    def find_warehouse!
      warehouse = Warehouse.find_by(id: @warehouse_id)

      return warehouse if warehouse.present?

      @order.errors.add(:warehouse, :required)
      raise ActiveRecord::Rollback
    end

    def find_product!
      product = Product.find_by(id: @product_id)

      return product if product.present?

      @order.errors.add(:product, :required)
      raise ActiveRecord::Rollback
    end

    def stock_balance
      @stock_balance ||= StockBalances.new(warehouse: @warehouse, product: @product)
    end

    def validate_available_stock!
      return true if stock_balance.available_stock > 0

      @order.errors.add(:stock, :unavailable)
      raise ActiveRecord::Rollback
    end

    def next_available_stock
      stock_balance.next_available_stock
    end
  end
end