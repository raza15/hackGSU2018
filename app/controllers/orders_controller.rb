require 'geokit'
include Geokit::Geocoders

class OrdersController < ApplicationController
  before_filter :set_gon
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  def maps_test_current_location
    session[:location] = "3423 Piedmont Rd NE, Atlanta, GA 30305, USA"
    redirect_to maps_test_path
  end

  def maps_test_post
    puts "lelz in maps_test_post... #{params} #{session[:location]}"
    session[:location] = params[:location]

    redirect_to maps_test_path
  end

  def maps_test
    @order = Order.find(1)
    coords = MultiGeocoder.geocode("25 Park Place NE, Atlanta, GA, USA")
    puts "lelz la la land"
    puts coords.lat
    puts coords.lng
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:order_id, :item_name, :item_quantity)
    end

    def set_gon
       gon.user_location = session[:location]
       if session[:location].nil?
          gon.user_location = "3423 Piedmont Rd NE, Atlanta, GA 30305, USA"
          # @time = "30 minutes"
       end
       if gon.user_location=="3423 Piedmont Rd NE, Atlanta, GA 30305, USA"
        @time = "30 minutes"
        gon.total_cost = "20 dollars"
       else
        @time = "10 minutes"
        gon.total_cost = "3 dollars"
       end
       session[:location] = gon.user_location
    end
end
