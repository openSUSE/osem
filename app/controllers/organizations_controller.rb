# frozen_string_literal: true

class OrganizationsController < ApplicationController
  load_and_authorize_resource :organization

  def index
    @organizations = Organization.all
  end

  def conferences
    @current = @organization.conferences.upcoming.reorder(start_date: :asc)
    @antiquated = @organization.conferences.past
    render '/conferences/index'
  end
end
