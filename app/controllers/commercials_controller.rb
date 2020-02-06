# frozen_string_literal: true

class CommercialsController < ApplicationController
  load_resource :conference, find_by: :short_title
  before_action :set_event
  load_and_authorize_resource through: :event
  skip_before_action :verify_authenticity_token

  def create
    @commercial = @event.commercials.build(commercial_params)
    authorize! :create, @commercial

    if @commercial.save
      redirect_to edit_conference_program_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  notice: 'Materials were successfully created.'
    else
      redirect_to edit_conference_program_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  error: "An error prohibited these materials from being saved: #{@commercial.errors.full_messages.join('. ')}."
    end
  end

  def update
    if @commercial.update(commercial_params)
      redirect_to edit_conference_program_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  notice: 'Materials were successfully updated.'
    else
      redirect_to edit_conference_program_proposal_path(conference_id: @conference.short_title, id: @event.id, anchor: 'commercials-content'),
                  error: "An error prohibited materials from being saved: #{@commercial.errors.full_messages.join('. ')}."
    end
  end

  def destroy
    @commercial.destroy
    redirect_to edit_conference_program_proposal_path(conference_id: @conference.short_title, id: @event.id),
                notice: 'Materials were successfully destroyed.'
  end

  def render_commercial
    result = Commercial.render_from_url(params[:url])
    if result[:error]
      render plain: result[:error], status: 400
    else
      render plain: result[:html]
    end
  end

  private

  def set_event
    @event = @conference.program.events.find(params[:proposal_id])
  end

  def commercial_params
    params.require(:commercial).permit(:url)
  end
end
