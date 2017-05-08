module Admin
  class VotableFieldsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :votable_field
    after_action :remove_rates, only: :destroy

    def index; end

    def edit; end

    def new
      @votable_field = @conference.votable_fields.new
    end

    def create
      @votable_field = @conference.votable_fields.new(votable_field_params)
      if @votable_field.save
        redirect_to admin_conference_votable_fields_path(@conference.short_title),
                    notice: 'Votable field successfully created.'
      else
        flash[:error] = "Creating votable field failed: #{@votable_field.errors.full_messages.join('. ')}."
        redirect_to new_admin_conference_votable_field_path(@conference.short_title)
      end
    end

    def update
      if @votable_field.update_attributes(votable_field_params)
        flash[:notice] = 'Votable field successfully updated'
        redirect_to admin_conference_votable_fields_path(@conference.short_title)
      else
        flash[:error] = "Votable field update failed: #{@votable_field.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @votable_field.destroy
        redirect_to admin_conference_votable_fields_path(@conference.short_title),
                    notice: 'Votable field successfully destroyed.'
      else
        redirect_to admin_conference_votable_fields_path(@conference.short_title),
                    error: 'Votable field could not be destroyed.' \
                    "#{@votable_field.errors.full_messages.join('. ')}."
      end
    end

    private

    def remove_rates
      false unless Rate.where(dimension: @votable_field.title).destroy_all && RatingCache.where(dimension: @votable_field.title).destroy_all
    end

    def votable_field_params
      params.require(:votable_field).permit(:title, :enabled, :votable_type, :conference_id, :for_admin, :stars)
    end
  end
end
