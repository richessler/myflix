require 'spec_helper'

describe StripeWrapper do
  let(:valid_token) do
    token = Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 1,
        :exp_year => 2018,
        :cvc => "314"
      },
    ).id       
  end
  let(:declined_card_token) do
    token = Stripe::Token.create(
      :card => {
        :number => "4000000000000002",
        :exp_month => 1,
        :exp_year => 2018,
        :cvc => "314"
      },
    ).id        
  end
  describe StripeWrapper::Charge do
    describe ".create" do
      it "it makes a successful charge", :vcr do
        response = StripeWrapper::Charge.create(
          amount: 999,
          card: valid_token,
          description: "a valid charge"
          )
        expect(response).to be_successful
      end
      
      it "handles the card decline", :vcr do
        response = StripeWrapper::Charge.create(
          amount: 999,
          card: declined_card_token,
          description: "card declined"
          )
        expect(response).not_to be_successful
      end
      
      it "returns the error message", :vcr do 
        response = StripeWrapper::Charge.create(
          amount: 999,
          card: declined_card_token,
          description: "card declined"
          )
        expect(response.error_message).to eq("Your card was declined.")
      end
    end
  end
  
  describe StripeWrapper::Customer do
    describe ".create" do
      it "creates a customer with a valid card", :vcr do
        user = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: user,
          card: valid_token
          )
        expect(response).to be_successful
      end    
      
      it "does not create a customer with a declined card", :vcr do
        user = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: user,
          card: declined_card_token
          )
        expect(response).not_to be_successful        
      end
      
      it "returns the error message for declined card", :vcr do
        user = Fabricate(:user)
        response = StripeWrapper::Customer.create(
        user: user,
        card: declined_card_token
        )
        expect(response.error_message).to eq("Your card was declined.")
      end
      
      it "returns the customer token for a valid card", :vcr do
        user = Fabricate(:user)
        response = StripeWrapper::Customer.create(
        user: user,
        card: valid_token
        )
        expect(response.customer_token).to be_present
      end
    end
  end
end