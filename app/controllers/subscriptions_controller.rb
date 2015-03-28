class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource only: [:create, :destroy], through: :conference

  def create
    @subscription = current_user.subscriptions.build(conference_id: @conference.id)
    if @subscription.save!
      flash[:notice] = "You have been subscribed to receive email notifications for #{@conference.short_title}."
      redirect_to root_path
    else
      flash[:error] = subscription.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end

  def destroy
    @subscription = current_user.subscriptions.find_by(conference_id: @conference.id)
    if @subscription.destroy
      flash[:notice] = "You have been unsubscribed and now you will not be receiving email notifications for #{@conference.short_title}."
      redirect_to root_path
    else
      flash[:error] = @subscription.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end
end
