class CommercialsController < ApplicationController
  load_resource :conference, find_by: :short_title
  before_action :set_event
  load_and_authorize_resource through: :event

  def create
    @commercial = @event.commercials.build(commercial_params)
    authorize! :create, @commercial

    if @commercial.save
      redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  notice: 'Commercial was successfully created.'
    else
      flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @commercial.update(commercial_params)
      redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  notice: 'Commercial was successfully updated.'
    else
      flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    @commercial.destroy
    redirect_to edit_conference_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                notice: 'Commercial was successfully destroyed.'
  end

  def get_html
    render text: Commercial.get_content(params[:url])
  end

  private

  def set_event
    @event = @conference.events.find(params[:proposal_id])
  end

  def commercial_params
    #params.require(:commercial).permit(:commercial_id, :commercial_type)
    params[:commercial]
  end
end
