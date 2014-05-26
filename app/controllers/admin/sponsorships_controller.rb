class Admin::SponsorshipsController < ApplicationController
  before_filter :verify_organizer

  def index
  end

  def create
    params[:sponsorship_registration][:conference_id] = @conference.id
    sponsorship = SponsorshipRegistration.new(params[:sponsorship_registration])
    if sponsorship.save
      redirect_to(admin_conference_sponsorships_path(:conference_id => @conference.short_title), :notice => "Sponsorship added")
    else
      redirect_to(admin_conference_sponsorships_path(:conference_id => @conference.short_title),
                 :alert => "Sponsorship creation failed.#{sponsorship.errors.full_messages.join('. ')}")
    end
  end
end
