# frozen_string_literal: true

module Spree
  module Api
    class PosOrderController < Spree::Api::OrdersController
      def create
        authorize! :create, Order
        order = Spree::Order.create(user: current_api_user, store: current_store)
        order.total = params[:total]
        respond_with(order)
      end
    end
  end
end
