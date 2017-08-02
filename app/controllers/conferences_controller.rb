class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title, except: :show

  def index
    @current = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
    @antiquated = @conferences - @current
  end

  def show
    @conference = if params[:id]
                    Conference.find_by_short_title(params[:id])
                  else
                    load_conference_by_domain
                  end
    authorize! :show, @conference
    @program = @conference.program
  end

  private

  def load_conference_by_domain
    Conference.find_by(custom_domain: request.domain)
  end

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
