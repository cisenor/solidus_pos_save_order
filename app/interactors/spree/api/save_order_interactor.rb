module Spree
  class Api::SaveOrderInteractor
    def initialize(store_repo = Spree::Store, address_repo = Spree::Address)
      @stores = store_repo
      @addresses = address_repo
    end

    def create(user, params)
      order = Spree::Order.create(user: user, store: @stores.find(params.fetch(:store_id)))
      sync_to_provided_params(order, params)
    end

    private

    def create_payments(order, payments)
      payment_method = Spree::PaymentMethod::POSPayment.first
      order.payments = payments.to_a.map do |payment|
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
      order.reload.recalculate
    end

    def create_line_items(order, line_items)
      line_items.each do |li|
        variant = Spree::Variant.find(li.fetch(:variant_id))
        order.contents.add(variant, li.fetch(:quantity, 0))
      end
      # order.reload.recalculate
    end

    def sync_to_provided_params(order, params)
      # cart
      create_line_items(order, params.fetch(:lineItems))
      # address
      # delivery
      # payment
      create_payments(order, params.fetch(:payments))
      # confirm
      # complete
      order.state = 'complete'
      order.shipment_state = 'shipped'
      order.payment_state = 'complete'
      order.finalize!
      order.save!
      order
    end
  end
end
