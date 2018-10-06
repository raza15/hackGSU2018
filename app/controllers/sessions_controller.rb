require 'rest-client'
require 'json'
require 'yaml'
require File.expand_path('../../../lib/visa_api_client', __FILE__)


class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :edit, :update, :destroy]

  # GET /sessions
  # GET /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/1
  # GET /sessions/1.json
  def show
  end

  def nearby_business
    
  end

  def inter_payment
    puts "leelz in inter_payment..."
    puts session[:location]
    if session[:location]=="3423 Piedmont Rd NE, Atlanta, GA 30305, USA"
      gon.speech = "Thank you for selecting three four two three Piedmont road Atlanta. Your order will reach you in 30 minutes."
    else
      gon.speech = "Thank you for selecting five eight one morgan street Atlanta. Your order will reach you in 10 minutes."
    end
  end

  def visa_checkout
    @config = YAML.load_file('configuration.yml')
    @visa_api_client = VisaAPIClient.new
    base_uri = 'wallet-services-web/'
    api_key = @config['apiKey']
    resource_path = 'payment/data/{callId}'
    resource_path = resource_path.sub('{callId}',@config['checkoutCallId'])
    response_code = @visa_api_client.doXPayTokenRequest(base_uri, resource_path, "apikey=#{api_key}", "Get Payment Information Test", "get", '')
  end

  # this is the CyberSource visa api
  def creditpayment
    cookies.delete :orders
    cookies.delete :coffee_order
    cookies.delete :coffee_quantity
    cookies.delete :coffee_size

   if gon.user_location=="3423 Piedmont Rd NE, Atlanta, GA 30305, USA"
    @time = "30 minutes"
    gon.total_cost = "20 dollars"
   else
    @time = "10 minutes"
    gon.total_cost = "3 dollars"
   end
  end

  # Simplify making a POST request
  def post(secureNetId, secureKey, body, url)
    uri = URI.parse(url)                       # Parse the URI
    http = Net::HTTP.new(uri.host, uri.port)   # New HTTP connection
    http.use_ssl = true                        # Must use SSL!
    req = Net::HTTP::Post.new(uri.request_uri) # HTTP POST request 
    req.body = body.to_json                    # Convert hash to json string
    req["Content-Type"] = 'application/json'   # JSON body
    req["Origin"] = 'worldpay.com'             # CORS origin
    req.basic_auth secureNetId, secureKey      # HTTP basic auth
    res = http.request(req)                    # Make the call
    return JSON.parse(res.body)                # Convert JSON to hashmap
  end

  def magic
    url = 'https://gwapi.demo.securenet.com/api/' # Root URL for REST calls
    secureNetId = '8011195'                       # Replace with your own ID
    secureKey = '6kGnYyjuVs4b'                    # Replace with your own Key

    # Step 1 - Create a customer
    puts "===== Create Customer ====="
    body = {
      firstName: 'Joe',
      lastName: 'Customer',
      phoneNumber: '512-122-1211',
      emailAddress: 'some@emailaddress.com',
      address: {
        line1: '123 Main St.',
        city: 'Austin',
        state: 'TX',
        zip: '78759'
      },
      company: 'Problem Unicorn',
      developerApplication: {
        developerId: 12345678,
        version: '1.2'
      }
    }
    cust_res = post(secureNetId, secureKey, body, url + 'customers')
    customer_id = cust_res["customerId"]
    puts "message: #{cust_res["message"]}"
    puts "customerId: #{customer_id}"

    # Step 2 - Add card to customer's vault
    puts "===== Create PaymentAccount ====="
    body = {
      card: {
        number: '4111111111111111',
        cvv: '123',
        expirationDate: '07/2018',
        address: {
          line1: '123 Main St.',
          city: 'Austin',
          state: 'TX',
          zip: '78759'
        }
      },
      developerApplication: {
        developerId: 12345678,
        version: '1.2'
      },
      accountDuplicateCheckIndicator: 0
    }
    account_res = post(secureNetId, secureKey, body, url + "customers/#{customer_id}/paymentmethod") 
    payment_id = account_res["vaultPaymentMethod"]["paymentId"]
    puts "message: #{account_res["message"]}"
    puts "paymentId: #{payment_id}"

    # Step 3 - Charge using the token
    puts "===== Sending charge using vaulted payment account ====="
    body = {
      amount: 11.00,
      paymentVaultToken: {
        customerId: customer_id,
        paymentMethodId: payment_id,
        paymentType: 'CREDIT_CARD'
      },
      developerApplication: {
        developerId: 12345678,
        version: '1.2'
      }
    }
    charge_res = post(secureNetId, secureKey, body, url + 'payments/charge') 
    puts "message: #{charge_res["message"]}"
    puts "transactionId: #{charge_res["transaction"]["transactionId"]}"
  end

  def end_transaction
    reset_session
    cookies.delete :orders
    cookies.delete :coffee_order
    cookies.delete :coffee_quantity
    cookies.delete :coffee_size
    cookies.delete :total_cost

    cookies[:orders] = []
    cookies[:coffee_order] = "coffee"
    cookies[:coffee_quantity] = 1
    cookies[:coffee_size] = "medium"
    # cookies[:total_cost] = 0
    session[:order_id] = 5
  end

  def creditpayment_process
    @config = YAML.load_file('configuration.yml')
    @visa_api_client = VisaAPIClient.new
    @paymentAuthorizationRequest='''{
      "amount": "0",
      "currency": "USD",
      "payment": {
        "cardNumber": "4111111111111111",
        "cardExpirationMonth": "10",
        "cardExpirationYear": "2020"
       }
    }'''
    base_uri = 'cybersource/'
    resource_path = 'payments/v1/authorizations'
    api_key = @config['apiKey']
    response_code = @visa_api_client.doXPayTokenRequest(base_uri, resource_path, "apikey=#{api_key}", "Payment Authorization Request test", "post", @paymentAuthorizationRequest)
    puts "hehe in credit payment..."
    puts response_code
    # assert_equal("201", response_code, "Payment Authorization test failed")
  end

  # GET /sessions/new
  def new
    reset_session
    cookies.delete :orders
    cookies.delete :coffee_order
    cookies.delete :coffee_quantity
    cookies.delete :coffee_size
    cookies.delete :total_cost

    cookies[:orders] = []
    cookies[:coffee_order] = "coffee"
    cookies[:coffee_quantity] = 1
    cookies[:coffee_size] = "medium"
    cookies[:total_cost] = 0
    @session = Session.new
    session[:order_id] = 5
  end

  # GET /sessions/1/edit
  def edit
  end

  # POST /sessions
  # POST /sessions.json
  def create
    @session = Session.new(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to @session, notice: 'Session was successfully created.' }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sessions/1
  # PATCH/PUT /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to @session, notice: 'Session was successfully updated.' }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.json
  def destroy
    @session.destroy
    respond_to do |format|
      format.html { redirect_to sessions_url, notice: 'Session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_params
      params.require(:session).permit(:order_id)
    end
end
