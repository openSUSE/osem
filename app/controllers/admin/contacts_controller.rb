module Admin
  class ContactsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    # GET /:conference/contact
    def show; end

    # GET /:conference/contact/edit
    def edit; end

    # PATCH/PUT /:conference/contact
    def update
      if @contact.update(contact_params)
        flash[:notice] = 'Contact details were successfully updated.'
        redirect_to edit_admin_conference_contact_path
      else
        flash[:error] = 'Contact details were not updated.'
        render :edit
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def contact_params
      # params.require(:contact).permit(:social_tag, :email, :facebook, :googleplus, :twitter, :instagram, :public)
      params[:contact]
    end
  end
end
