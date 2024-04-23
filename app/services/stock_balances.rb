class StockBalances
  def initialize(warehouse:, product:)
    @warehouse = warehouse
    @product = product
    @stocks = Stock.includes(:orders)
      .where(warehouse_id: @warehouse.id, product_id: @product.id)
      .where("quantity > 0")
      .order(id: :asc)
  end

  def generate
    {
      warehouse_id: @warehouse.id,
      warehouse_code: @warehouse.code,
      product_id: @product.id,
      product_code: @product.code,
      available_stock: available_stock,
      ordered_stock: ordered_stock
    }
  end

  def available_stock
    @stocks.sum(&:quantity) - ordered_stock
  end

  def next_available_stock
    @stocks.find { |stock| stock.quantity > stock.orders.received.count }
  end

  private

  def ordered_stock
    @ordered_stock ||= @stocks.sum { |stock| stock.orders.received.count }
  end
end
