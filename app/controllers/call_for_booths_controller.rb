class CallForBoothsController < ApplicationController
  before_action :set_call_for_booth, only: [:show, :edit, :update, :destroy]

  # GET /call_for_booths
  # GET /call_for_booths.json
  def index
    @call_for_booths = CallForBooth.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @call_for_booths }
    end
  end

  # GET /call_for_booths/1
  # GET /call_for_booths/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @call_for_booth }
    end
  end

  # GET /call_for_booths/new
  def new
    @call_for_booth = CallForBooth.new
  end

  # GET /call_for_booths/1/edit
  def edit
  end

  # POST /call_for_booths
  # POST /call_for_booths.json
  def create
    @call_for_booth = CallForBooth.new(call_for_booth_params)

    respond_to do |format|
      if @call_for_booth.save
        format.html { redirect_to @call_for_booth, notice: 'Call for booth was successfully created.' }
        format.json { render json: @call_for_booth, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @call_for_booth.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /call_for_booths/1
  # PATCH/PUT /call_for_booths/1.json
  def update
    respond_to do |format|
      if @call_for_booth.update(call_for_booth_params)
        format.html { redirect_to @call_for_booth, notice: 'Call for booth was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @call_for_booth.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /call_for_booths/1
  # DELETE /call_for_booths/1.json
  def destroy
    @call_for_booth.destroy
    respond_to do |format|
      format.html { redirect_to call_for_booths_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_call_for_booth
      @call_for_booth = CallForBooth.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def call_for_booth_params
      params.require(:call_for_booth).permit(:start_date, :end_date, :booth_limit)
    end
end
