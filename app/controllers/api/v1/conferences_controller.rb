class Api::V1::ConferencesController < Api::BaseController
  respond_to :json

  def index
    respond_with Conference.all
  end
end
