require 'rails_helper'

RSpec.describe Spree::Api::PosOrderController, type: :controller do
  before do
    @routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw { post 'create', to: 'spree/api/pos_order#create' }
    end
  end
  describe "GET #create" do
    it "returns http success" do
      post :create, params: Hash[
        "order": {
          "version": 1,
          "clerkId": 123,
          "number": "R12314",
          "total": 350.00,
          "initializedTime": "Tue Mar 24 2015 17:00:00 GMT-0700 (PDT)",
          "finalizedTime": null,
          "associatedCustomer": "A@B.com",
          "lineItems": [],
          "gift": false,
          "payments": [],
          "promotions": [],
          "owing": 0,
          "taxes": []
        }
      ]
      expect(response).to have_http_status(302)
    end
  end
end
