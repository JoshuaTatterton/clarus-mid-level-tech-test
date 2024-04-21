describe Order do
  let(:product) { Product.create(code: "test") }
  let(:warehouse) { Warehouse.create(code: "test") }
  let(:stock) { Stock.create(quantity: 10, product: product, warehouse: warehouse) }

  it "has access to product and warehouse through the stock" do
    # Act
    order = Order.create(stock: stock)

    # Assert
    expect(order.reload.product).to eq(product)
    expect(order.warehouse).to eq(warehouse)
  end

  it "defaults status to `received`" do
    # Act
    order = Order.create(stock: stock)

    # Assert
    expect(order.status).to eq("received")
  end
end
