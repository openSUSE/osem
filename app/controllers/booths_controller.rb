class BoothsController < ApplicationController
  before_action :set_booth, only: [:show, :edit, :update, :destroy]

  # GET /booths
  def index
    @booths = Booth.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /booths/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /booths/new
  def new
    @booth = Booth.new
  end

  # GET /booths/1/edit
  def edit
  end

  # POST /booths
  def create
    @booth = Booth.new(booth_params)

    respond_to do |format|
      if @booth.save
        format.html { redirect_to @booth, notice: 'Booth was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /booths/1
  def update
    respond_to do |format|
      if @booth.update(booth_params)
        format.html { redirect_to @booth, notice: 'Booth was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /booths/1
  def destroy
    @booth.destroy
    respond_to do |format|
      format.html { redirect_to booths_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booth
      @booth = Booth.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booth_params
      params.require(:booth).permit(:title, :conference_id, :description, :state, :reasoning, :logo_link)
    end
end
