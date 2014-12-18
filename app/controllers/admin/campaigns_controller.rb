module Admin
  class CampaignsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :campaign, through: :conference

    def index
      authorize! :index, Campaign.new(conference_id: @conference.id)
      @campaigns = @conference.campaigns
    end

    def create
      @campaign.attributes = params[:campaign]

      if @conference.save
        flash[:notice] = 'Campaign successfully created.'
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title))
      else
        flash[:error] = 'Campaign creation failed. ' + @campaign.errors.full_messages.to_sentence
        render action: 'new'
      end
    end

    def new; end

    def edit; end

    def update
      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = "Campaign '#{@campaign.name}' successfully updated."
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Campaign update failed.  #{@campaign.errors.full_messages.to_sentence}"
        render action: 'edit'
      end
    end

    def destroy
      if @campaign.destroy
        flash[:notice] = "Campaign '#{@campaign.name}' successfully deleted."
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Delete of Campaign for #{@conference.short_title} failed." \
                    "#{@campaign.errors.full_messages.join('. ')}."
        redirect_to(admin_conference_campaigns_path(conference_id: @conference.short_title))
      end
    end
  end
end
