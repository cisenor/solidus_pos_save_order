module Spree
  class Api::SaveOrderInteractor
    def initialize(
        store_repo = Spree::Store,
        address_repo = Spree::Address,
        user_repo = Spree::User
        )
      @stores = store_repo
      @addresses = address_repo
      @users = user_repo
    end

    def create(user, params)
      currency = params.dig(:store, :currency)
      store_id = params.dig(:store, :id)
      unless currency.casecmp('usd') == 0
        raise(ArgumentError, 'Currency must be in USD')
      end
      order = Spree::Order.create(user: user, store: @stores.find(store_id))
      sync_to_provided_params(order, params)
    end

    private

    def sync_to_provided_params(order, params)
      # TODO: I don't like this process
      order = create_line_items(order, params.fetch(:lineItems))
      order.currency = params.dig(:store, :currency)
      order = create_payments(order, params.fetch(:payments))
      order = attach_address(order, params.dig(:store, :id))
      order.number = params.fetch(:number)
      order = associate_user(order, params.fetch(:associatedCustomer))
      finish(order)
    end

    def attach_address(order, store_id)
      address_id = @stores.find(store_id).address_id
      address = @addresses.find(address_id)
      order.ship_address = address
      order.bill_address = address
      order
    end

    def associate_user(order, user_email)
      user = @users.find(:first, conditions: ["email = ?", user_email])
      order.user = user
      order.email = user.email
      order
    end

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
        pm.save!
        pm
      end
      order
    end

    def create_line_items(order, line_items)
      line_items.each do |li|
        variant = Spree::Variant.find(li.fetch(:variant_id))
        order.contents.add(variant, li.fetch(:quantity, 0))
      end
      order
    end

    def finish(order)
      order.state = 'complete'
      order.finalize!
      order.save!
      order
    end
  end
end
