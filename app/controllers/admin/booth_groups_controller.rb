# frozen_string_literal: true

module Admin
  class BoothGroupsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :booth_group, through: :program

    def index; end

    def edit; end

    def new
      @booth_group = @conference.program.booth_groups.new(color: @conference.next_color_for_collection(:booth_groups))
    end

    def create
      @booth_group = @conference.program.booth_groups.new(booth_group_params)
      if @booth_group.save
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    notice: "#{(t 'booth').capitalize} group successfully created."
      else
        flash.now[:error] = "Creating #{t 'booth'} group failed: #{@booth_group.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @booth_group.update_attributes(booth_group_params)
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    notice: "#{(t 'booth').capitalize} group successfully updated."
      else
        flash.now[:error] = "Update #{t 'booth'} group failed: #{@booth_group.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @booth_group.destroy
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    notice: "#{(t 'booth').capitalize} group successfully deleted."
      else
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    error: "Destroying #{t 'booth'} group failed! "\
                    "#{@booth_group.errors.full_messages.join('. ')}."
      end
    end

    private

    def booth_group_params
      params.require(:booth_group).permit(:name, :color, :conference_id,
                                          :created_at, :updated_at, booth_ids: [])
    end
  end
end
