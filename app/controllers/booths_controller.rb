# frozen_string_literal: true

class BoothsController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource through: :conference
  skip_authorize_resource only: [:withdraw, :confirm, :restart]

  def index
    @booths = current_user.booths.where(conference_id: @conference.id).uniq
  end

  def show; end

  def new
    @url = conference_booths_path(@conference.short_title)
  end

  def create
    @url = conference_booths_path(@conference.short_title)

    @booth.submitter = current_user

    if @booth.save
      redirect_to conference_booths_path,
                  notice: "#{(t 'booth').capitalize} successfully created."
    else
      flash.now[:error] = "Creating #{t 'booth'} failed. #{@booth.errors.full_messages.to_sentence}."
      render :new
    end
  end

  def edit
    @url = conference_booth_path(@conference.short_title, @booth.id)
  end

  def update
    @url = conference_booth_path(@conference.short_title, @booth.id)
    @booth.update_attributes(booth_params)

    if @booth.save
      redirect_to conference_booths_path,
                  notice: 'Booth successfully updated!'
    else
      flash.now[:error] = "Booth could not be updated. #{@booth.errors.full_messages.to_sentence}."
      render :edit
    end
  end

  def destroy; end

  def withdraw
    authorize! :update, @booth
    @url = conference_booth_path(@conference.short_title, @booth.id)

    @booth.withdraw!

    if @booth.save
      redirect_to conference_booths_path,
                  notice: 'Booth successfully withdrawn'
    else
      flash.now[:error] = "Booth could not be withdrawn. #{@booth.errors.full_messages.to_sentence}."
    end
  end

  def confirm
    authorize! :update, @booth
    @url = conference_booth_path(@conference.short_title, @booth.id)

    @booth.confirm!

    if @booth.save
      redirect_to conference_booths_path,
                  notice: 'Booth successfully confirmed'
    else
      flash.now[:error] = "Booth could not be confirmed. #{@booth.errors.full_messages.to_sentence}."
    end
  end

  def restart
    authorize! :update, @booth
    @url = conference_booth_path(@conference.short_title, @booth.id)

    @booth.restart!

    if @booth.save
      redirect_to conference_booths_path,
                  notice: 'Booth successfully re-submitted'
    else
      flash.now[:error] = "Booth could not be re-submitted. #{@booth.errors.full_messages.to_sentence}."
    end
  end

  private

  def booth_params
    params.require(:booth).permit(:title, :description, :reasoning, :state, :picture, :conference_id,
                                  :created_at, :updated_at, :submitter_relationship, :website_url, responsible_ids: [])
  end
end
