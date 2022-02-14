# frozen_string_literal: true

module Admin
  class DifficultyLevelsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource through: :program

    def index
#       authorize! :index, DifficultyLevel.new(program_id: @program.id)
    end

    def edit; end

    def new
      @difficulty_level = @conference.program.difficulty_levels.new(color: @conference.next_color_for_collection(:levels))
    end

    def create
      @difficulty_level = @conference.program.difficulty_levels.new(difficulty_level_params)
      if @difficulty_level.save
        redirect_to admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title),
                    notice: 'Difficulty level successfully created.'
      else
        flash.now[:error] = "Creating difficulty level failed: #{@difficulty_level.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @difficulty_level.update(difficulty_level_params)
        redirect_to admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title),
                    notice: 'Difficulty level successfully updated.'
      else
        flash.now[:error] = "Update difficulty level failed: #{@difficulty_level.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @difficulty_level.destroy
        redirect_to admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title),
                    notice: 'Difficulty level successfully deleted.'
      else
        redirect_to admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title),
                    error: 'Deleting difficulty level type failed! '\
                    "#{@difficulty_level.errors.full_messages.join('. ')}."
      end
    end

    private

    def difficulty_level_params
      params.require(:difficulty_level).permit(:title, :description, :color, :conference_id)
    end
  end
end
