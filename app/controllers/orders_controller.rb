class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show update destroy ]

  # GET /orders
  def index
    @orders = Order.includes(:stock).all

    render json: @orders
  end

  # POST /orders
  def create
    @order = Order.new
    order_persister = Persisters::CreateOrder.new(
      order: @order,
      warehouse_id: order_params[:warehouse_id],
      product_id: order_params[:product_id]
    )

    if order_persister.call
      render json: @order, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # GET /orders/1
  def show
    render json: @order
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.includes(:stock).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(:warehouse_id, :product_id)
  end
end
