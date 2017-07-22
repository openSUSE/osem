class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def index
    @current = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
    @antiquated = @conferences - @current
  end

  def show
    # have to change "localhost" to ENV['OSEM_HOSTNAME'] in production 
    check_custom_domain if request.host != 'localhost'
  end

  private

  def check_custom_domain
    @conference = @conference.custom_domain.present? ? Conference.find_by(custom_domain: request.domain) : @conference
  end

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
