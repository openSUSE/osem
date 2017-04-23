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
                    notice: 'Commercial was successfully created.'
      else
        redirect_to admin_conference_commercials_path,
                    error: 'An error prohibited this Commercial from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."

      end
    end

    def update
      if @commercial.update(commercial_params)
        redirect_to admin_conference_commercials_path,
                    notice: 'Commercial was successfully updated.'
      else
        redirect_to admin_conference_commercials_path,
                    error: 'An error prohibited this Commercial from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."
      end
    end

    def destroy
      @commercial.destroy
      redirect_to admin_conference_commercials_path, notice: 'Commercial was successfully destroyed.'
    end

    def render_commercial
      result = Commercial.render_from_url(params[:url])
      if result[:error]
        render text: result[:error], status: 400
      else
        render text: result[:html]
      end
    end

    private

    def commercial_params
      params.require(:commercial).permit(:url)
    end
  end
end
