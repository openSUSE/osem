class Api::V1::ConferencesController < Api::BaseController
  respond_to :json

  def index
    render :json => Conference.all, :serializer => ConferencesArraySerializer
  end
end
