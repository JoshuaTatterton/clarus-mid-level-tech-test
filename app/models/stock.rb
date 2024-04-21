class Stock < ApplicationRecord
  belongs_to :warehouse
  belongs_to :product

  has_many :orders
end
