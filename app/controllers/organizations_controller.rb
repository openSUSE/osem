class OrganizationsController < ApplicationController
  load_and_authorize_resource :organization

  def index
    @organizations = Organization.all
  end
end
