class CommercialsController < ApplicationController
  before_action :set_conference
  before_action :set_event
  before_action :set_commercial, only: [:edit, :update, :destroy]

  def new
    @commercial = @event.commercials.build
  end

  def edit
  end

  def create
    @commercial = @event.commercials.build(commercial_params)

    if @commercial.save
      redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id),
                  notice: 'Commercial was successfully created.'
    else
      flash[:alert] = "A error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @commercial.update(commercial_params)
      redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id),
                  notice: 'Commercial was successfully updated.'
    else
      flash[:alert] = "A error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    @commercial.destroy
    redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id),
                notice: 'Commercial was successfully destroyed.'
  end

  private

  def set_commercial
    @commercial = @event.commercials.find(params[:id])
  end

  def set_conference
    @conference = Conference.find_by(short_title: params[:conference_id])
  end

  def set_event
    @event = @conference.events.find(params[:proposal_id])
  end

  def commercial_params
    #params.require(:commercial).permit(:commercial_id, :commercial_type)
    params[:commercial]
  end
end
