# frozen_string_literal: true

module Spree
  module Api
    class PosOrderController < Spree::Api::OrdersController
      respond_to :json
      def create
        authorize! :create, Order
        interactor = Spree::Api::SaveOrderInteractor.new
        order = interactor.create(current_api_user, params)
        render json: order, status: 201
      end
    end
  end
end
