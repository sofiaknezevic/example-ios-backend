require 'sinatra'
require 'stripe'
require 'dotenv'
require 'json'
require 'encrypted_cookie'
require 'net/http'
require 'uri'

Dotenv.load

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

get '/' do
  status 200
  return "Great, your backend is set up."
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
      }, :stripe_account => "sk_live_OOQFeeRAONJc9ewcmmQ6FhHT")
    rescue Stripe::StripeError => e
      status 402
      return "Error creating charge: #{e.message}"
  end

  status 200
  return JSON.generate(charge)

end
