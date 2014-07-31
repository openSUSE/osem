class Admin::VenuesController < ApplicationController
  before_filter :verify_organizer
  before_action :set_venue, only: [:update, :edit]

  def update
    @venue.assign_attributes(venue_params)
    venue_notify = (@venue.name_changed? || @venue.address_changed?) &&
                   (!@venue.name.blank? && !@venue.address.blank?) &&
                   (@conference.email_settings.send_on_venue_update &&
                   !@conference.email_settings.venue_update_subject.blank? &&
                   @conference.email_settings.venue_update_template)

    if @venue.save
      Mailbot.delay.send_email_on_venue_update(@conference) if venue_notify
      redirect_to(:back, notice: 'Venue was successfully updated.')
    else
      redirect_to(:back,
                  notice: 'Venue Updation Failed!')
    end
  end

  def edit
  end

  private

  def venue_params
    params[:venue]
  end

  def set_venue
    @venue = @conference.venue
  end
end
