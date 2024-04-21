class Order < ApplicationRecord
  belongs_to :stock

  has_one :product, through: :stock
  has_one :warehouse, through: :stock

  enum :status, { received: 0, dispatched: 1 }
end
