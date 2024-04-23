describe StockBalanceController, type: :request do
  describe "#show" do
    let(:product) { Product.create(code: "test_product") }
    let(:warehouse) { Warehouse.create(code: "test_warehouse") }

    it "returns a json object representation of stock objects for provided warehouse and product" do
      # Arrange
      stock = Stock.create(quantity: 10, product: product, warehouse: warehouse)
      Order.create(stock: stock)
      Order.create(stock: stock, status: :dispatched)

      # Act
      get "/stock_balance/#{warehouse.id}/#{product.id}"

      # Assert
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq({
        warehouse_id: warehouse.id,
        warehouse_code: "test_warehouse",
        product_id: product.id,
        product_code: "test_product",
        available_stock: "9.0",
        ordered_stock: 1
      })
    end

    it "returns a valid json object when no stock objects are available" do
      # Act
      get "/stock_balance/#{warehouse.id}/#{product.id}"

      # Assert
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq({
        warehouse_id: warehouse.id,
        warehouse_code: warehouse.code,
        product_id: product.id,
        product_code: product.code,
        available_stock: 0,
        ordered_stock: 0
      })
    end

    context "returns an error" do
      it "when an invalid warehouse id is provided" do
        # Act
        get "/stock_balance/invalid_id/#{product.id}"

        # Assert
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq({
          warehouse: ["Warehouse not found for: invalid_id"]
        })
      end

      it "when an invalid product id is provided" do
        # Act
        get "/stock_balance/#{warehouse.id}/wrong_id"

        # Assert
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq({
          product: ["Product not found for: wrong_id"]
        })
      end
    end
  end
end
