describe StocksController, type: :request do
  let(:product) { Product.create(code: "test_product") }
  let(:warehouse) { Warehouse.create(code: "test_warehouse") }

  describe "#index" do
    it "returns found orders with appropriate data" do
      # Arrange
      stock = Stock.create(product: product, warehouse: warehouse)
      order_1 = Order.create(stock: stock)
      order_2 = Order.create(stock: stock, status: :dispatched)

      # Act
      get "/orders"

      # Assert
      aggregate_failures do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body, symbolize_names: true)).to match_array([
          hash_including(
            id: order_1.id,
            stock_id: stock.id,
            status: "received",
            product_id: product.id,
            warehouse_id: warehouse.id
          ),
          hash_including(
            id: order_2.id,
            stock_id: stock.id,
            status: "dispatched",
            product_id: product.id,
            warehouse_id: warehouse.id
          )
        ])
      end
    end
  end

  describe "#create" do
    context "when valid order details provided" do
      context "and stock is available" do
        it "creates an order" do
          # Arrange
          stock = Stock.create(quantity: 5, product: product, warehouse: warehouse)

          # Act & Assert
          expect {
            post "/orders", params: { order: { warehouse_id: warehouse.id, product_id: product.id } }
          }.to change(Order, :count).by(1)

          # Assert
          aggregate_failures do
            created_order = Order.last
            expect(response.status).to eq(201)
            expect(JSON.parse(response.body, symbolize_names: true)).to include(
              id: created_order.id,
              stock_id: stock.id,
              status: "received"
            )
          end
        end
      end
    end

    context "when invalid stock details provided" do
      it "returns an error" do
        # Act & Assert
        expect {
          post "/stocks", params: { stock: { quantity: "a", warehouse_id: "unknown_id", product_id: "unknown_id" } }
        }.to change(Stock, :count).by(0)

        # Assert
        aggregate_failures do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            warehouse: ["must exist"],
            product: ["must exist"]
          })
        end
      end
    end
  end

  describe "#show" do
    it "returns found order with appropriate data" do
      # Arrange
      stock = Stock.create(product: product, warehouse: warehouse)
      order = Order.create(stock: stock)

      # Act
      get "/orders/#{order.id}"

      # Assert
      aggregate_failures do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body, symbolize_names: true)).to include(
          id: order.id,
          stock_id: stock.id,
          status: "received",
          product_id: product.id,
          warehouse_id: warehouse.id
        )
      end
    end
  end

  describe "#update" do
    context "when a valid order with stock is provided" do
      it "updates the order status and decreases the stock quantity" do
        # Arrange
        stock = Stock.create(quantity: 5, product: product, warehouse: warehouse)
        order = Order.create(stock: stock)

        # Act
        patch "/dispatch_order/#{order.id}"

        # Assert
        aggregate_failures do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body, symbolize_names: true)).to include(
            id: order.id,
            stock_id: stock.id,
            status: "dispatched"
          )
          expect(stock.reload.quantity).to eq(4)
        end
      end
    end

    context "when an already dispatched order is provided" do
      it "returns an error" do
        # Arrange
        stock = Stock.create(quantity: 5, product: product, warehouse: warehouse)
        order = Order.create(stock: stock, status: :dispatched)

        # Act
        patch "/dispatch_order/#{order.id}"

        # Assert
        aggregate_failures do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body, symbolize_names: true)).to include(
            status: ["already has been dispatched"]
          )
          expect(stock.reload.quantity).to eq(5)
        end
      end
    end
  end
end
