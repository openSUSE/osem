# frozen_string_literal: true

module Admin
  class CommercialsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, except: [:new, :create]

    def index
      @commercials = @conference.commercials

      @commercial = @conference.commercials.build
    end

    def create
      @commercial = @conference.commercials.build(commercial_params)
      authorize! :create, @commercial

      if @commercial.save
        redirect_to admin_conference_commercials_path,
                    notice: 'Materials were successfully created.'
      else
        redirect_to admin_conference_commercials_path,
                    error: 'An error prohibited materials from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."

      end
    end

    def update
      if @commercial.update(commercial_params)
        redirect_to admin_conference_commercials_path,
                    notice: 'Materials were successfully updated.'
      else
        redirect_to admin_conference_commercials_path,
                    error: 'An error prohibited materials from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."
      end
    end

    def destroy
      @commercial.destroy
      redirect_to admin_conference_commercials_path, notice: 'Materials were successfully removed.'
    end

    def render_commercial
      result = Commercial.render_from_url(params[:url])
      if result[:error]
        render plain: result[:error], status: 400
      else
        render plain: result[:html]
      end
    end

    ##
    # Received a file from user
    # Reads file and creates commercial for event
    # File content example:
    # EventID:MyURL
    def mass_upload
      errors = Commercial.read_file(params[:file]) if params[:file]

      if !params[:file]
        flash[:error] = 'Empty file detected while adding materials to Event'
      elsif errors.all? { |_k, v| v.blank? }
        flash[:notice] = 'Successfully added materials.'
      else
        errors_text = ''
        errors_text += 'Unable to find event with ID: ' + errors[:no_event].join(', ') + '. ' if errors[:no_event].any?
        errors_text += 'There were some errors: ' + errors[:validation_errors].join('. ') if errors[:validation_errors].any?

        flash[:error] = errors_text
      end
      redirect_back(fallback_location: root_path)
    end

    private

    def commercial_params
      params.require(:commercial).permit(:url)
    end
  end
end
