describe Persisters::CreateOrder do
  let(:product) { Product.create(code: "test_product") }
  let(:warehouse) { Warehouse.create(code: "test_warehouse") }

  describe "#call" do
    context "when the warehouse exists" do
      context "when the product exists" do
        context "when stock is available" do
          it "stores the order" do
            # Arrange
            stock = Stock.create(quantity: 1, product: product, warehouse: warehouse)
            order = Order.new
            persister = Persisters::CreateOrder.new(order: order, product_id: product.id,  warehouse_id: warehouse.id)

            # Act
            result = persister.call

            # Assert
            aggregate_failures do
              expect(result).to be_truthy
              expect(order).to be_persisted
              expect(order.stock_id).to eq(stock.id)
            end
          end
        end

        context "when no stock is available" do
          it "exits with an error on the order" do
            # Arrange
            order = Order.new
            persister = Persisters::CreateOrder.new(order: order, product_id: product.id,  warehouse_id: warehouse.id)

            # Act
            result = persister.call

            # Assert
            aggregate_failures do
              expect(result).to be_falsey
              expect(order).not_to be_persisted
              expect(order.errors.attribute_names).to include(:stock)
            end
          end
        end
      end

      context "when the product doesn't exist" do
        it "exits with an error on the order" do
          # Arrange
          order = Order.new
          persister = Persisters::CreateOrder.new(order: order, product_id: "unknown_id",  warehouse_id: warehouse.id)

          # Act
          result = persister.call

          # Assert
          aggregate_failures do
            expect(result).to be_falsey
            expect(order).not_to be_persisted
            expect(order.errors.attribute_names).to include(:product)
          end
        end
      end
    end

    context "when the warehouse doesn't exist" do
      it "exits with an error on the order" do
        # Arrange
        order = Order.new
        persister = Persisters::CreateOrder.new(order: order, product_id: product.id,  warehouse_id: "unknown_id")

        # Act
        result = persister.call

        # Assert
        aggregate_failures do
          expect(result).to be_falsey
          expect(order).not_to be_persisted
          expect(order.errors.attribute_names).to include(:warehouse)
        end
      end
    end
  end
end


# context "when no stock is available" do
#   it "exits with an error on the order" do
#     # Arrange
#     stock = Stock.create(quantity: 1, product: product, warehouse: warehouse)
#     order = Order.new
#     persister = Persisters::CreateOrder.new(order: order, product_id: product.id,  warehouse_id: warehouse.id)

#     # Act
#     result = persister.call

#     # Assert
#     aggregate_failures do
#       expect(result).to be_falsey
#       expect(order).not_to be_persisted
#       expect(order.errors.attribute_names).to include(:stock)
#     end
#   end
# end