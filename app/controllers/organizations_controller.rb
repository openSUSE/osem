class OrganizationsController < ApplicationController
	load_and_authorize_resource :organization

	def index
		@organizations = Organization.all
	end

	def create
		@organization = Organization.new(organization_params)
		if @organization.save
			redirect_to organizations_path,
			notice: 'Organization successfully created'
		else
			redirect_to new_organization_path,
			error: @organization.errors.full_messages.join(', ')
		end
	end

	def new
		@organization = Organization.new
	end

	def edit
	end

	def update
		if @organization.update_attributes(organization_params)
			redirect_to organizations_path,
			notice: 'Organization successfully updated'
		else
			redirect_to edit_organization_path(@organization),
			error: @organization.errors.full_messages.join(', ')
		end
	end

	private

	def organization_params
		params.require(:organization).permit(:name, :description, :picture)
	end
end
