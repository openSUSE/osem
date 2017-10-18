module Admin
  class CampaignsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :campaign, through: :conference

    def index
      authorize! :index, Campaign.new(conference_id: @conference.id)
      @campaigns = @conference.campaigns
    end

    def create
      @campaign.attributes = campaign_params

      if @conference.save
        redirect_to admin_conference_campaigns_path(conference_id: @conference.short_title),
                    notice: 'Campaign successfully created.'
      else
        flash.now[:error] = 'Campaign creation failed. ' + @campaign.errors.full_messages.to_sentence
        render action: 'new'
      end
    end

    def new; end

    def edit; end

    def update
      if @campaign.update_attributes(campaign_params)
        redirect_to admin_conference_campaigns_path(conference_id: @conference.short_title),
                    notice: "Campaign '#{@campaign.name}' successfully updated."
      else
        flash.now[:error] = "Campaign update failed.  #{@campaign.errors.full_messages.to_sentence}"
        render action: 'edit'
      end
    end

    def destroy
      if @campaign.destroy
        redirect_to admin_conference_campaigns_path(conference_id: @conference.short_title),
                    notice: "Campaign '#{@campaign.name}' successfully deleted."
      else
        redirect_to admin_conference_campaigns_path(conference_id: @conference.short_title),
                    error: "Delete of Campaign for #{@conference.short_title} failed."\
                    "#{@campaign.errors.full_messages.join('. ')}."
      end
    end

    private

    def campaign_params
      params.require(:campaign).permit(:name, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_campaign, :target_ids, :conference_id)
    end
  end
end
