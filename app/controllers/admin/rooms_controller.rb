class Admin::RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy]
  before_action :set_conference

  def index
    @rooms = @conference.rooms
  end

  def new
    @room = @conference.rooms.build
  end

  def edit
  end

  def create
    @room = @conference.rooms.build(room_params)

    if @room.save
      redirect_to admin_conference_rooms_path(@conference.short_title), notice: 'Room was successfully created.'
    else
      flash[:alert] = "A error prohibited this Rooms from being saved: #{@room.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @room.update(room_params)
      redirect_to admin_conference_rooms_path(@conference.short_title), notice: 'Room was successfully updated.'
    else
      flash[:alert] = "A error prohibited this Rooms from being saved: #{@room.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    @room.destroy
    redirect_to admin_conference_rooms_path, notice: 'Room was successfully destroyed.'
  end

  private

  def set_conference
    @conference = Conference.find_by(short_title: params[:conference_id])
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params[:room]
  end
end
