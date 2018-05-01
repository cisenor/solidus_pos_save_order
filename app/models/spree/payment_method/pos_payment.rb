# frozen_string_literal: true

module Spree
  # Payment method to be used for any POS payment.
  # This is sparse because we know the POS payment has already been approved
  class PaymentMethod::POSPayment < PaymentMethod
    def actions
      %w{}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def capture(*)
      simulated_successful_billing_response
    end

    def void(*)
      simulated_successful_billing_response
    end
    alias_method :try_void, :void

    def credit(*)
      simulated_successful_billing_response
    end

    def source_required?
      false
    end

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end
  end
end
