module Admin
  class VersionsController < Admin::BaseController
    load_resource :conference, find_by: :short_title
    load_and_authorize_resource class: PaperTrail::Version

    def index
      @conf_ids_with_role = current_user.is_admin? ? Conference.pluck(:short_title) : Conference.with_role([:organizer, :cfp, :info_desk], current_user).pluck(:short_title)

      return unless @conference.present?
      authorize! :index, PaperTrail::Version.new(conference_id: @conference.id)
      @versions = @versions.where(conference_id:  @conference.id)
    end

    def revert_attribute
      if params[:attribute] && @version.changeset.reject{ |_, values| values[0].blank? && values[1].blank? }.keys.include?(params[:attribute])
        if @version.item[params[:attribute]] == @version.changeset[params[:attribute]][0]
          flash[:error] = 'The item is already in the state that you are trying to revert it back to'

        else
          @version.item[params[:attribute]] = @version.changeset[params[:attribute]][0]
          if @version.item.save
            flash[:notice] = 'The selected change was successfully reverted'
          else
            flash[:error] = "An error prohibited this change from being reverted: #{@version.item.errors.full_messages.join('. ')}."
          end
        end

      else
        flash[:error] = 'Revert failed. Attribute missing or invalid'
      end

      redirect_back_or_to admin_revision_history_path
    end

    def revert_object
      if @version.event != 'create'
        if @version.reify.save
          flash[:notice] = 'The selected change was successfully reverted'
        else
          flash[:error] = "An error prohibited this change from being reverted: #{@version.reify.errors.full_messages.join('. ')}."
        end

      elsif @version.event == 'create' && @version.item
        # if @version represets a create event and is not currently deleted
        @version.item.destroy
        flash[:notice] = 'The selected change was successfully reverted'

      else
        flash[:error] = 'The item is already in the state that you are trying to revert it back to'
      end

      redirect_back_or_to admin_revision_history_path
    end
  end
end
