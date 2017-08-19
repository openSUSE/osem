module Admin
  class ConferenceDomainsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title

    def show
      # To only allow organizers, organization admin and site administrators
      authorize! :update, @conference
      redirect_to admin_conference_conference_domains_edit_path(@conference.short_title) unless @conference.custom_domain.present?
    end

    def edit
      authorize! :edit, @conference
    end

    def update
      authorize! :update, @conference
      @conference.assign_attributes(conference_params)
      if @conference.save
        redirect_to admin_conference_conference_domain_path(@conference.short_title),
                    notice: 'Attached new domain name to conference. This does not mean that the new domain should work. Please make sure you follow step 3 to point your domain to this hosted version'
      else
        redirect_to admin_conference_conference_domains_edit_path(@conference.short_title),
                    notice: 'Failed to add the new domain as custom domain to the conference'
      end
    end

    private

    def conference_params
      params.require(:conference).permit(:custom_domain)
    end
  end
end
