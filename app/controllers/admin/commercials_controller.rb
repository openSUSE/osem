module Admin
  class CommercialsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, except: [:new, :create]

    def index
      @commercials = @conference.commercials
    end

    def new
      @commercial = @conference.commercials.build
      authorize! :create, @conference.commercials.new
    end

    def edit; end

    def create
      @commercial = @conference.commercials.build(commercial_params)
      authorize! :create, @commercial

      if @commercial.save
        redirect_to admin_conference_commercials_path,
                    notice: 'Commercial was successfully created.'
      else
        flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @commercial.update(commercial_params)
        redirect_to admin_conference_commercials_path,
                    notice: 'Commercial was successfully updated.'
      else
        flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      @commercial.destroy
      redirect_to admin_conference_commercials_path, notice: 'Commercial was successfully destroyed.'
    end

    private

    def commercial_params
      #params.require(:commercial).permit(:commercial_id, :commercial_type)
      params[:commercial]
    end
  end
end
