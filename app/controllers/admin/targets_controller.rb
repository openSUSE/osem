module Admin
  class TargetsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :target, through: :conference

    def index
      authorize! :update, Target.new(conference_id: @conference.id)
    end

    def new
      @target = @conference.targets.new
    end

    def create
      @target = @conference.targets.new(target_params)
      if @target.save(target_params)
        flash[:notice] = 'Target successfully created.'
        redirect_to admin_conference_targets_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Creating target failed: #{@target.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @target.update_attributes(target_params)
        flash[:notice] = 'Target successfully updated.'
        redirect_to admin_conference_targets_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Target update failed: #{@target.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @target.destroy
        flash[:notice] = 'Target successfully destroyed.'
        redirect_to admin_conference_targets_path(conference_id: @conference.short_title)
      else
        flash[:error] = 'Target was successfully destroyed.' \
                        "#{@target.errors.full_messages.join('. ')}."
        redirect_to admin_conference_targets_path(conference_id: @conference.short_title)
      end
    end

    private

    def target_params
      params[:target]
    end
  end
end
