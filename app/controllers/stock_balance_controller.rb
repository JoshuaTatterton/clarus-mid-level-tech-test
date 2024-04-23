class StockBalanceController < ApplicationController
  before_action :validate_warehouse_and_product_exist

  # GET /stock_balance/:warehouse_id/:product_id
  def show
    @stock_balance = StockBalances.new(warehouse: @warehouse, product: @product)

    render json: @stock_balance.generate
  end

  private

  WAREHOUSE_NOT_FOUND_LOCALE = "controllers.stock_balance_controller.show.warehouse_not_found"
  PRODUCT_NOT_FOUND_LOCALE = "controllers.stock_balance_controller.show.product_not_found"

  def validate_warehouse_and_product_exist
    @warehouse = Warehouse.find_by(id: params[:warehouse_id])
    @product = Product.find_by(id: params[:product_id])

    if @warehouse.blank? || @product.blank?
      render json: {
        warehouse: @warehouse.present? ? nil : [I18n.t(WAREHOUSE_NOT_FOUND_LOCALE, id: params[:warehouse_id])],
        product: @product.present? ? nil : [I18n.t(PRODUCT_NOT_FOUND_LOCALE, id: params[:product_id])]
      }.compact, status: :not_found
    end
  end
end
