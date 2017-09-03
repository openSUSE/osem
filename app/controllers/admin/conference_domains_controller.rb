module Admin
  class ConferenceDomainsController < Admin::BaseController
    load_resource :conference, find_by: :short_title

    def new
      # To only allow organizers, organization admin and site administrators
      authorize! :update, @conference
    end

    def show
      # To only allow organizers, organization admin and site administrators
      authorize! :update, @conference
      redirect_to new_admin_conference_domain_path(@conference.short_title) unless @conference.custom_domain.present?
    end

    def edit
      authorize! :update, @conference
    end

    def update
      authorize! :update, @conference
      @conference.assign_attributes(conference_params)
      if @conference.save
        redirect_to admin_conference_domain_path(@conference.short_title),
                    notice: 'Attached new domain name to conference. This does not mean that the new domain should work. Please make sure you follow step 3 to point your domain to this hosted version'
      else
        redirect_to edit_admin_conference_domain_path(@conference.short_title),
                    error: 'Failed to add the new domain as custom domain to the conference'
      end
    end

    def destroy
      authorize! :update, @conference
      @conference.custom_domain = nil
      if @conference.save
        redirect_to new_admin_conference_domain_path(@conference.short_title),
                    notice: 'Custom domain successfully removed from conference'
      else
        redirect_to admin_conference_domain_path(@conference.short_title),
                    error: 'Failed o remove custom domain from the conference'
      end
    end

    private

    def conference_params
      params.require(:conference).permit(:custom_domain)
    end
  end
end
