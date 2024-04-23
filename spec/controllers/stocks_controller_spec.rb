describe StocksController, type: :request do
  describe "#create" do
    let(:product) { Product.create(code: "test_product") }
    let(:warehouse) { Warehouse.create(code: "test_warehouse") }

    context "when valid stock details provided" do
      it "creates a stock" do
        # Act & Assert
        expect {
          post "/stocks", params: { stock: { quantity: 10, warehouse_id: warehouse.id, product_id: product.id } }
        }.to change(Stock, :count).by(1)

        # Assert
        created_stock = Stock.last
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body, symbolize_names: true)).to include(
          id: created_stock.id,
          warehouse_id: warehouse.id,
          product_id: product.id,
          quantity: "10.0"
        )
      end
    end

    context "when invalid stock details provided" do
      it "returns an error" do
        # Act & Assert
        expect {
          post "/stocks", params: { stock: { quantity: "a", warehouse_id: "unknown_id", product_id: "unknown_id" } }
        }.to change(Stock, :count).by(0)

        # Assert
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq({
          warehouse: ["must exist"],
          product: ["must exist"]
        })
      end
    end
  end
end
