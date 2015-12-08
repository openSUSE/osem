module Admin
  class SplashpagesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show; end

    def new
      @splashpage = @conference.build_splashpage
    end

    def edit; end

    def create
      @splashpage = @conference.build_splashpage(splashpage_params)

      if @splashpage.save
        flash[:notice] = 'Splashpage successfully created.'
        redirect_to admin_conference_splashpage_path
      else
        flash[:error] = 'Splashpage could not be created.'\
                        "#{@splashpage.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @splashpage.update_attributes(splashpage_params)
        redirect_to admin_conference_splashpage_path,
                    notice: 'Splashpage successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      if @splashpage.destroy
        flash[:notice] = 'Splashpage was successfully destroyed.'
        redirect_to admin_conference_splashpage_path
      else
        flash[:error] = 'An error prohibited this Splashpage from being destroyed: '\
                        "#{@splashpage.errors.full_messages.join('. ')}."
        redirect_to admin_conference_splashpage_path
      end
    end

    private

    def splashpage_params
      params[:splashpage]
    end
  end
end
