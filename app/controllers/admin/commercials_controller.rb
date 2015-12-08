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
        flash[:notice] = 'Commercial was successfully created.'
        redirect_to admin_conference_commercials_path
      else
        flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @commercial.update(commercial_params)
        flash[:notice] = 'Commercial was successfully updated.'
        redirect_to admin_conference_commercials_path
      else
        flash[:error] = "An error prohibited this Commercial from being saved: #{@commercial.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @commercial.destroy
        flash[:notice] = 'Commercial was successfully destroyed.'
        redirect_to admin_conference_commercials_path
      else
        flash[:error] = 'Commercial was not destroyed.'\
                        "#{@commercial.errors.full_messages.join('. ')}"
        redirect_to admin_conference_commercials_path
      end
    end

    private

    def commercial_params
      #params.require(:commercial).permit(:commercial_id, :commercial_type)
      params[:commercial]
    end
  end
end
