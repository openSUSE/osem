class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def index
    domain = request.host
    @current = Conference.get_conferences_to_list domain
    @antiquated = @conferences - @current
  end

  def show; end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
