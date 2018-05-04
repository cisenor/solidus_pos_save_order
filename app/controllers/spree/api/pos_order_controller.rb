# frozen_string_literal: true

module Spree
  module Api
    class PosOrderController < Spree::Api::OrdersController
      respond_to :json
      def create
        authorize! :create, Order
        order = Spree::Order.create(user: current_api_user, store: current_store)
        order.total = params[:total]
        render json: order, status: 201
      end
    end
  end
end
