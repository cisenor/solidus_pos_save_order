# frozen_string_literal: true

module Spree
  module Api
    class PosOrderController < Spree::Api::OrdersController
      respond_to :json
      def create
        authorize! :create, Order
        order = Spree::Order.create(user: current_api_user, store: current_store)
        order = sync_to_provided_params(order)
        order.store = Spree::Store.first
        order.state = 'complete'
        order.shipment_state = 'shipped'
        order.payment_state = 'complete'
        order.finalize!
        order.save!
        render json: order, status: 201
      end

      private

      def create_payments(order)
        payment_method = Spree::PaymentMethod::POSPayment.first
        order.payments = params.fetch(:payments).to_a.map do |payment|
          amount = payment.fetch(:amount)
          pay = Spree::PaymentCreate.new(order, {
            amount: amount,
            payment_method: payment_method,
            source_type: payment_method.type,
            source_id: payment_method.id
          })
          pm = pay.build
          pm.state = 'completed'
          pm
        end
        # order.reload.recalculate
      end

      def create_line_items(order)
        params.fetch(:lineItems).each do |li|
          variant = Spree::Variant.find(li.fetch(:variant_id))
          order.contents.add(variant, li.fetch(:quantity, 0))
        end
        # order.reload.recalculate
      end

      def source_type(type)
        Spree::CreditCard if type == 'credit-card'
      end

      def sync_to_provided_params(order)
        # cart
        create_line_items(order)
        # address
        # delivery
        # payment
        create_payments(order)
        # confirm
        # complete
        order
      end
    end
  end
end
