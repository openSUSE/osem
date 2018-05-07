# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource only: [:create, :destroy], through: :conference

  def create
    @subscription = current_user.subscriptions.build(conference_id: @conference.id)
    if @subscription.save
      redirect_to root_path, notice: "You have subscribed to receive email notifications for #{@conference.title}."
    else
      redirect_to root_path, error: @subscription.errors.full_messages.to_sentence
    end
  end

  def destroy
    @subscription = current_user.subscriptions.find_by(conference_id: @conference.id)

    redirect_to(root_path, error: "You are not subscribed to #{@conference.title}.") && return unless @subscription
    if @subscription.destroy
      redirect_to root_path, notice: "You have unsubscribed and you will not be receiving email notifications for #{@conference.title}."
    else
      redirect_to root_path, error: @subscription.errors.full_messages.to_sentence
    end
  end
end
