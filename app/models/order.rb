class Order < ApplicationRecord
  belongs_to :stock

  has_one :product, through: :stock
  has_one :warehouse, through: :stock

  enum :status, { received: 0, dispatched: 1 }

  delegate :product_id, :warehouse_id, to: :stock

  def as_json(options = nil)
    super(options).merge(product_id: product_id, warehouse_id: warehouse_id)
  end
end
