class Api::V1::SpeakersController < Api::BaseController
  respond_to :json

  def index
    if params[:conference_id].blank?
      people = User.joins(:event_users)
    else
      people = User.joins(:event_users => {:event => :conference})
      people = people.where("conferences.guid" => params[:conference_id])
    end
    people = people.where("event_users.event_role" => "speaker")
    render :json => users, :each_serializer => SpeakerSerializer
  end
end
