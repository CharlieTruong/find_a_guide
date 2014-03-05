class ToursController < ApplicationController
  def edit
    # delete this
    puts params
  end

  def update
    respond_to do |format|
      # don't invent new keys
      if Tour.update(params[:tour_id], description: params[:description])
        format.json do
          render :json => {message: "SUCCESS!"}
        end
      else
        format.json do
          render :json =>{message: "FAILURE!"}
        end
      end
    end
  end

  def new
    gon.points = []
    @ambassador = current_user
    gon.id = @ambassador.id
    @tours = @ambassador.tours

    @tours.each do |tour|
      gon.points << tour.format_object
    end
  end

  def create
    # @tour = Tour.new(description: params[:description], latitude: params[:latitude], longitude: params[:longitude], ambassador_id: params[:user_id])
    @tour = Tour.new(tour_params)
    @tour.ambassador_id = params[:user_id] # security? what if I set a params[:user_id] client side? maybe use curren_user
    respond_to do |format|
      format.json do
        if @tour.save
          render :json => {message: "SUCCESS!", success: true, tour_id: @tour.id}
        else
          render :json => {message: "Unable to save post", success: false}
        end
      end
    end
  end

  def index
    # you have before filter for this, don't reinvent it here
    if current_user
      @ambassador = User.find(params[:user_id])
      @start_date = session[:start_date]
      @end_date = session[:end_date]
    else
      redirect_to '/auth/facebook/callback'
    end
  end

  private
  def tour_params
    params.require(:tour).permit(:description, :latitude, :longitude, :user_id)
  end

end
