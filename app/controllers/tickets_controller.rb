# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_resource :ticket, through: :conference
  authorize_resource :conference_registrations, class: Registration
  before_action :check_load_resource, only: :index

  def index; end

  def check_load_resource
    if @tickets.empty?
      redirect_to root_path, notice: "There are no tickets available for #{@conference.title}!"
    end
  end
end
