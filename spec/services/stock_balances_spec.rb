describe StockBalances do
  let(:product) { Product.create(code: "test_product") }
  let(:warehouse) { Warehouse.create(code: "test_warehouse") }

  describe "#generate" do
    it "outputs a json object containing stock balance data" do
      # Arrange
      stock = Stock.create(quantity: 10, product: product, warehouse: warehouse)
      Order.create(stock: stock)
      stock_balance = StockBalances.new(product: product, warehouse: warehouse)

      # Act
      data = stock_balance.generate

      # Assert
      expect(data).to eq({
        warehouse_id: warehouse.id,
        warehouse_code: "test_warehouse",
        product_id: product.id,
        product_code: "test_product",
        available_stock: 9,
        ordered_stock: 1
      })
    end
  end

  describe "#available_stock" do
    it "available stock is sum of stock quantity minus received order count" do
      # Arrange
      ordered_stock = Stock.create(quantity: 10, product: product, warehouse: warehouse)
      full_stock = Stock.create(quantity: 5, product: product, warehouse: warehouse)
      Order.create(stock: ordered_stock)
      Order.create(stock: ordered_stock)
      Order.create(stock: ordered_stock, status: :dispatched)
      stock_balance = StockBalances.new(product: product, warehouse: warehouse)

      # Act
      available_stock = stock_balance.available_stock

      # Assert
      expect(available_stock).to eq(13)
    end
  end

  describe "#next_available_stock" do
    it "available stock is sum of stock quantity minus received order count" do
      # Arrange
      fully_ordered_stock = Stock.create(quantity: 1, product: product, warehouse: warehouse)
      Order.create(stock: fully_ordered_stock)
      Order.create(stock: fully_ordered_stock, status: :dispatched)

      available_stock = Stock.create(quantity: 2, product: product, warehouse: warehouse)
      Order.create(stock: available_stock)
      Order.create(stock: available_stock, status: :dispatched)

      excess_stock = Stock.create(quantity: 10, product: product, warehouse: warehouse)
      
      stock_balance = StockBalances.new(product: product, warehouse: warehouse)

      # Act
      next_available_stock = stock_balance.next_available_stock

      # Assert
      expect(next_available_stock).to eq(available_stock)
    end
  end

  describe "#ordered_stock" do
    it "count of stock received orders" do
      # Arrange
      stock_1 = Stock.create(quantity: 10, product: product, warehouse: warehouse)
      stock_2 = Stock.create(quantity: 5, product: product, warehouse: warehouse)
      Order.create(stock: stock_1)
      Order.create(stock: stock_2)
      Order.create(stock: stock_2, status: :dispatched)
      stock_balance = StockBalances.new(product: product, warehouse: warehouse)

      # Act
      ordered_stock = stock_balance.send(:ordered_stock)

      # Assert
      expect(ordered_stock).to eq(2)
    end
  end
end
