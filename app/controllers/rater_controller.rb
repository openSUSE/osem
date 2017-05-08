class RaterController < ApplicationController
  load_and_authorize_resource :rate

  def create
    if user_signed_in?
      votable_type = ''
      VotableField::VALID_VOTABLE_TYPES.each do |valid_votable_type|
        votable_type = valid_votable_type
        break if params[:klass] == votable_type
      end
      obj = votable_type.classify.constantize.find(params[:id])
      obj.rate params[:score].to_f, current_user, params[:dimension]

      render json: true
    else
      render json: false
    end
  end
end
