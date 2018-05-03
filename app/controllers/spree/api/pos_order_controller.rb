# frozen_string_literal: true

module Spree
  module Api
    class PosOrderController < Spree::Api::OrdersController
      respond_to :json
      def create
        authorize! :create, Order
        begin
          interactor = Spree::Api::SaveOrderInteractor.new
          order = interactor.create(current_api_user, params)
          render json: order, status: 201
        rescue StandardError => e
          render json: e, status: 422
        end
      end
    end
  end
end
