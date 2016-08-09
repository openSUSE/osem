module Admin
  class VersionsController < Admin::BaseController
    skip_authorization_check

    def index
      authorize! :index, PaperTrail::Version.new(item_type: 'User')
      conf_ids_for_organizer = current_user.is_admin? ? Conference.pluck(:id) : Conference.with_role(:organizer, current_user).pluck(:id)
      @versions = PaperTrail::Version.where(["conference_id IN (?) OR item_type = 'User'", conf_ids_for_organizer])
    end

    def revert_attribute
      @version = PaperTrail::Version.find(params[:id])
      authorize! :revert_attribute, @version

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
      @version = PaperTrail::Version.find(params[:id])
      authorize! :revert_object, @version

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
