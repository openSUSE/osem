class Api::V1::SpeakersController < Api::BaseController
  respond_to :json

  def index
    if params[:conference_id].blank?
      people = Person.joins(:event_people)
    else
      people = Person.joins(:event_people => {:event => :conference})
      people = people.where("conferences.guid" => params[:conference_id])
    end
    people = people.where("event_people.event_role" => "speaker")
    render :json => people, :each_serializer => SpeakerSerializer
  end
end
