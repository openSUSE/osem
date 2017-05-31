module Admin
  class OrganizationsController < Admin::BaseController
    load_and_authorize_resource :organization

    def index
      @organizations = Organization.all
    end

    def destroy
      if @organization.destroy
        redirect_to admin_organizations_path,
                    notice: 'Organization successfully destroyed'
      else
        redirect_to admin_organizations_path,
                    error: 'Organization cannot be destroyed'
      end
    end
  end
end
