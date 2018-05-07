# frozen_string_literal: true

module Admin
  class OrganizationsController < Admin::BaseController
    load_and_authorize_resource :organization
    before_action :verify_user, only: [:assign_org_admins, :unassign_org_admins]

    def index
      @organizations = Organization.all
    end

    def create
      @organization = Organization.new(organization_params)
      if @organization.save
        redirect_to admin_organizations_path,
                    notice: 'Organization successfully created'
      else
        redirect_to new_admin_organization_path,
                    error: @organization.errors.full_messages.join(', ')
      end
    end

    def new
      @organization = Organization.new
    end

    def edit; end

    def update
      if @organization.update_attributes(organization_params)
        redirect_to admin_organizations_path,
                    notice: 'Organization successfully updated'
      else
        redirect_to edit_admin_organization_path(@organization),
                    error: @organization.errors.full_messages.join(', ')
      end
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

    def assign_org_admins
      if @user.has_cached_role? 'organization_admin', @organization
        flash[:error] = "User #{@user.email} already has the role organization admin"
      elsif @user.add_role 'organization_admin', @organization
        flash[:notice] = "Successfully added role organization admin to user #{@user.email}"
      else
        flash[:error] = "Coud not add role organization admin to #{@user.email}"
      end

      redirect_to admins_admin_organization_path(@organization)
    end

    def unassign_org_admins
      if @user.remove_role 'organization_admin', @organization
        flash[:notice] = "Successfully removed role organization admin from user #{@user.email}"
      else
        flash[:error] = "Could not remove role organization admin from user #{@user.email}"
      end

      redirect_to admins_admin_organization_path(@organization)
    end

    def admins
      @role = @organization.roles.first
      @users = @role.users
      render 'show_org_admins'
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end

    def verify_user
      @user = User.find_by(email: user_params[:email])
      unless @user
        redirect_to admins_admin_organization_path(@organization),
                    error: 'Could not find user. Please provide a valid email!'
        return
      end
    end

    def organization_params
      params.require(:organization).permit(
        :name, :description, :picture, :code_of_conduct
      )
    end
  end
end
