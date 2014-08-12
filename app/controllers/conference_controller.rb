class ConferenceController < ApplicationController
  load_and_authorize_resource find_by: :short_title

  def show
  end

  def subscribe
    conference = Conference.find_by_short_title(params[:id])
    if current_user.subscriptions.where(conference: conference).blank?
      subscription = Subscription.new(user_id: current_user.id, conference_id: conference.id)
      begin
        subscription.save!
        flash[:success] = "You have been subscribed to receive Email Notifications from this Conference."
        redirect_to root_path
      rescue ActiveRecord::RecordInvalid
        flash[:error] = subscription.errors.full_messages.to_sentence
        redirect_to root_path
      end
    else
      flash[:notice] = "Already Subscribed"
      redirect_to root_path
    end
  end

  def unsubscribe
    conference = Conference.find_by_short_title(params[:id])
    subscription = current_user.subscriptions.where(conference_id: conference.id).first
    if subscription.blank?
      flash[:notice] = "Already Unsubscribed"
      redirect_to root_path
    else
     begin
        subscription.destroy!
        flash[:notice] = "You have been unsubscribed and now you won't be receiving any Email Notifications."
        redirect_to root_path
      rescue ActiveRecord::RecordInvalid
        flash[:error] = subscription.errors.full_messages.to_sentence
        redirect_to root_path
      end
    end
  end

  def gallery_photos
    @photos = @conference.photos
    render "photos", formats: [:js]
  end
end
