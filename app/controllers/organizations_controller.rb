# frozen_string_literal: true

class OrganizationsController < ApplicationController
  load_and_authorize_resource :organization

  def index
    @organizations = Organization.all
  end

  def code_of_conduct
    @title = "#{@organization.name}: Code of Conduct"
    @content = @organization.code_of_conduct
    render 'document'
  end

  def conferences
    @current = @organization.conferences.upcoming.reorder(start_date: :asc)
    @antiquated = @organization.conferences.past
    render '/conferences/index'
  end
end
