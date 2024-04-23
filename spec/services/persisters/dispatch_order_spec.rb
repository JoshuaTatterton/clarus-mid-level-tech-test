describe Persisters::DispatchOrder do
  let(:product) { Product.create(code: "test_product") }
  let(:warehouse) { Warehouse.create(code: "test_warehouse") }

  describe "#call" do
    context "with a received order" do
      context "when stock is available" do
        it "updates the order status and decrements the Order Stock" do
          # Arrange
          stock = Stock.create(quantity: 1, product: product, warehouse: warehouse)
          order = Order.create(stock: stock)
          persister = Persisters::DispatchOrder.new(order: order)

          # Act
          result = persister.call

          # Assert
          aggregate_failures do
            expect(result).to be_truthy
            expect(order.reload.status).to eq("dispatched")
            expect(stock.reload.quantity).to eq(0)
          end
        end
      end

      context "when stock is unavailable" do
        it "exits with an error on the order" do
          # Arrange
          stock = Stock.create(quantity: 0, product: product, warehouse: warehouse)
          order = Order.create(stock: stock)
          persister = Persisters::DispatchOrder.new(order: order)

          # Act
          result = persister.call

          # Assert
          aggregate_failures do
            expect(result).to be_falsey
            expect(order.reload.status).to eq("received")
            expect(stock.reload.quantity).to eq(0)
            expect(order.errors.attribute_names).to include(:stock)
          end
        end
      end
    end

    context "with an already dispatched order" do
      it "exits with an error on the order" do
        # Arrange
        stock = Stock.create(quantity: 1, product: product, warehouse: warehouse)
        order = Order.create(stock: stock, status: :dispatched)
        persister = Persisters::DispatchOrder.new(order: order)

        # Act
        result = persister.call

        # Assert
        aggregate_failures do
          expect(result).to be_falsey
          expect(stock.reload.quantity).to eq(1)
          expect(order.errors.attribute_names).to include(:status)
        end
      end
    end
  end

  describe "#decrement_stock_quantity!" do
    context "when stock quantity is 0" do
      it "cannot update to negative quantity" do
        # Arrange
        stock = Stock.create(quantity: 0, product: product, warehouse: warehouse)
        order = Order.create(stock: stock)
        persister = Persisters::DispatchOrder.new(order: order)

        # Act
        Order.transaction do
          persister.send(:decrement_stock_quantity!)
        end

        # Assert
        aggregate_failures do
          expect(stock.reload.quantity).to eq(0)
          expect(order.errors.attribute_names).to include(:stock)
        end
      end
    end
  end
end