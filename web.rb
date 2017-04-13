require 'sinatra'
require 'stripe'
require 'dotenv'
require 'json'
require 'encrypted_cookie'

Dotenv.load
Stripe.api_key = ENV['SECRET_KEY']

use Rack::Session::EncryptedCookie,
  :secret => ENV['SECRET_KEY'] # Actually use something secret here!

get '/' do
  status 200
  return "Great, your backend is set up."
end

post '/charge' do
  authenticate!
  # Get the credit card details submitted by the form
  source = params[:source]

  # Create the charge on Stripe's servers - this will charge the user's card
  begin
    charge = Stripe::Charge.create(
      :amount => params[:amount], # this number should be in cents
      :currency => "cad",
      :customer => @customer.id,
      :source => source,
      :description => "Example Charge"
    )
  rescue Stripe::StripeError => e
    status 402
    return "Error creating charge: #{e.message}"
  end

  status 200
  return "Charge successfully created"
end

get '/customer' do
  authenticate!
  status 200
  content_type :json
  @customer.to_json
end

post '/create_token' do

  number = params[:number]
  exp_month = params[:exp_month]
  exp_year = params[:exp_year]
  cvc = params[:cvc]

  begin
    card = Stripe::Token.create(
      :card => {
        :number => number,
        :exp_month => exp_month,
        :exp_year => exp_year,
        :cvc => cvc
      },
    )

  rescue Stripe::StripeError => e
    status 402
    return "Error creating charge: #{e.message}"
  end

  status 200
  return JSON.generate(card)

end

post '/charge_connected_account' do

  amount = params[:amount]
  currency = params[:currency]
  source = params[:source]
  stripe_account = params[:stripe_account]


  begin
    charge = Stripe::Charge.create({
      :amount => amount,
      :currency => currency,
      :source => source,
      }, :stripe_account => stripe_account)

    rescue Stripe::StripeError => e
      status 402
      return "Error creating charge: #{e.message}"
  end

  status 200
  return JSON.generate(charge)

end


# This endpoint is used by the Obj-C example app to create a charge.
# post '/create_charge' do
#   # Create the charge on Stripe's servers
#   begin
#     charge = Stripe::Charge.create(
#       :amount => params[:amount], # this number should be in cents
#       :currency => "usd",
#       :source => params[:source],
#       :description => "Example Charge"
#     )
#
#     puts "inside create_charge, #{source}"
#   rescue Stripe::StripeError => e
#     status 402
#     return "Error creating charge: #{e.message}"
#   end
#
#   status 200
#   return "Charge successfully created"
# end
