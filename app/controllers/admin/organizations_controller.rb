class Admin::OrganizationsController < ApplicationController
  before_filter :verify_organizer
  respond_to :html

  def index
    @organizations = Organization.all
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
    flash[:notice] = 'Organization was successfully created.' if @organization.save
    respond_with @organization, location: admin_organizations_path
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    flash[:notice] = 'Organization was successfully updated' 
                      if @organization.update_attributes(params[:organization])
    respond_with @organization, location: admin_organizations_path
  end

  def delete
    @organization = Organization.find(params[:id])
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy
    redirect_to admin_organizations_path, notice: 'Organization got deleted'
    
  end
end
