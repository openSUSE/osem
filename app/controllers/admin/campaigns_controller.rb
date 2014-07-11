module Admin
  class CampaignsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :campaign, through: :conference

    def index
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaigns = @conference.campaigns
    end

    def create
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaign = @conference.campaigns.new(params[:campaign])
      @campaign.conference_id = @conference.id

      if @conference.save
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title),
                    notice: 'Campaign successfully created.')
      else
        redirect_to(new_admin_conference_campaign_path(conference_id: @conference.short_title),
                    alert: "Creating of Campaign for #{@conference.short_title} failed." \
                    "#{@campaign.errors.full_messages.join('. ')}.")
      end
    end

    def new
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaign = @conference.campaigns.new
    end

    def edit
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaign = Campaign.find(params[:id])
    end

    def update
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaign = Campaign.find(params[:id])

      if @campaign.update_attributes(params[:campaign])
        redirect_to(admin_conference_campaigns_path(
                        conference_id: @conference.short_title),
                    notice: "Campaign '#{@campaign.name}' successfully updated.")
      else
        redirect_to(edit_admin_conference_campaign_path(
                        conference_id: @conference.short_title,
                        id: @campaign.id),
                    alert: "Update of Campaign for #{@conference.short_title} failed." \
                    "#{@campaign.errors.full_messages.join('. ')}.")
      end
    end

    def destroy
      @conference = Conference.find_by(short_title: params[:conference_id])
      @campaign = Campaign.find(params[:id])
      if @campaign.destroy
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title),
                    notice: "Campaign '#{@campaign.name}' successfully deleted.")
      else
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title),
                    alert: "Delete of Campaign for #{@conference.short_title} failed." \
                    "#{@campaign.errors.full_messages.join('. ')}.")
      end
    end
  end
end
