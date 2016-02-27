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
      @difficulty_level = @conference.program.difficulty_levels.new
    end

    def create
      @difficulty_level = @conference.program.difficulty_levels.new(difficulty_level_params)
      if @difficulty_level.save
        flash[:notice] = 'Difficulty level successfully created.'
        redirect_to(admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Creating difficulty level failed: #{@difficulty_level.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @difficulty_level.update_attributes(difficulty_level_params)
        flash[:notice] = 'Difficulty level successfully updated.'
        redirect_to(admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Update difficulty level failed: #{@difficulty_level.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @difficulty_level.destroy
        flash[:notice] = 'Difficulty level successfully deleted.'
        redirect_to(admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title))
      else
        flash[:error] = 'Deleting difficulty level type failed! ' \
        "#{@difficulty_level.errors.full_messages.join('. ')}."
        redirect_to(admin_conference_program_difficulty_levels_path(conference_id: @conference.short_title))
      end
    end

    private

    def difficulty_level_params
      params.require(:difficulty_level).permit(:title, :description, :color, :conference_id)
    end
  end
end
