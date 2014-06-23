class Api::V1::EventsController < Api::BaseController
  respond_to :json

  def index
    events = Event.includes(:conference, :track, :room, :event_type, {:event_user => :user})
    unless params[:conference_id].blank?
      events = events.where("conferences.guid" => params[:conference_id])
    end
    respond_with events.confirmed
  end
end
