
require 'rails_helper'

RSpec.describe Spree::Api::SaveOrderInteractor, type: :model do
  let(:address) { FactoryBot.create(:address) }
  let(:store) { FactoryBot.create(:store, address_id: address.id) }
  let(:store_repo) { instance_double('stores', find: store) }
  let(:variants) { [FactoryBot.create(:variant), FactoryBot.create(:variant)] }
  let(:address_repo){ instance_double('addresses', find: address) }
  let(:user_repo) do
    instance_double(
      'users',
      find: FactoryBot.create(:user, email: params.fetch(:associatedCustomer))
    )
  end
  let(:user) { FactoryBot.create(:user, :with_api_key) }
  let(:order_params) { import_json('../order', :from_hanami) }
  let(:params) do
    v1, v2 = variants
    parameters = order_params
    parameters[:lineItems][0][:variant_id] = v1.id
    parameters[:lineItems][1][:variant_id] = v2.id
    parameters[:store_id] = store.id
    parameters
  end

  let(:payments) do
    pay = params.fetch(:payments)
    pay.inject(0) { |sum, p| sum + p.fetch(:amount).to_d }
  end

  let(:item_count) do
    li = params.fetch(:lineItems)
    li.inject(0) { |sum, line_item| sum + line_item.fetch(:quantity).to_i }
  end

  before(:each) do
    Spree::PaymentMethod::POSPayment.create(name: 'Test')
  end

  context 'with valid parameters' do
    let(:saved_order) do
      interactor = described_class.new(store_repo, address_repo, user_repo)
      interactor.create(user, params)
    end
    it 'the final total is equal to the provided total' do
      expect(saved_order.display_total.to_d).to eq params.fetch(:total)
    end
    it 'the final item count is equal to the total number of items' do
      expect(saved_order.item_count).to eq item_count
    end
    it 'the final payment total is equal to the provided total' do
      expect(saved_order.payment_total).to eq payments
    end
    it 'the shipping address and billing address are equal to the supplied store' do
      expect(saved_order.ship_address.id).to eq address.id
      expect(saved_order.bill_address.id).to eq address.id
      expect(Spree::Order.last.ship_address.id).to eq address.id
    end
    it 'the final order number matches the provided order number' do
      expect(saved_order.number).to eq params.fetch(:number)
    end
    it 'the final state is "complete"' do
      expect(saved_order.state).to eq "complete"
    end
    it 'the final email matches the associated customer' do
      expect(saved_order.email.downcase).to eq params.fetch(:associatedCustomer).downcase
    end
    it 'the final currency matches the provided currency' do
      expect(saved_order.currency).to eq params.dig(:store, :currency)
    end
    it 'the final store ID matches the provided store' do
      expect(saved_order.store_id).to eq params.fetch(:store_id)
    end
    context 'the database' do
      it 'contains a new record for each of the line items' do
        order = saved_order
        line_items = Spree::LineItem.where(order_id: order.id)
        expect(line_items.size).to eq params.fetch(:lineItems).size
      end
      it 'contains a new record for each of the payments' do
        order = saved_order
        payments = Spree::Payment.where(order_id: order.id)
        expect(payments.size).to eq params.fetch(:payments).size
      end
    end
  end
end
