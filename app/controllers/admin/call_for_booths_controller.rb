module Admin
  class CallForBoothsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show
    end


    def new
      @call_for_booths = CallForBooth.new(conference: @conference)
    end

    def edit; end

    def create
      @call_for_booth = @conference.call_for_booth.build(call_for_booth_params)

      if @call_for_booth.save
        redirect_to admin_conference_call_for_booth_path,
                    notice: "Call for booths successfully created."
      else
        flash[:error] = "Creating the call for booths failed. #{@call_for_booth.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      @call_for_booth = @conference.call_for_booth
      @call_for_booth.assign_attributes(call_for_booth_params)

      if @call_for_booth.update_attributes(call_for_booth_params)
        redirect_to admin_conference_call_for_booth_path(@conference.short_title),
                    notice: 'Call for booths successfully updated.'
      else
        flash.now[:error] = "Updating call for booths failed. #{@call_for_booth.errors.to_a.join('. ')}."
        render :new
      end
    end

    def destroy
      if @call_for_booth.destroy
        redirect_to admin_conference_call_for_booth_path, notice: 'Call for Booths successfully deleted.'
      else
        redirect_to admin_conference_call_for_booth_path, error: 'An error prohibited this Call for Booths from being destroyed: '\
        "#{@call_for_booth.errors.full_messages.join('. ')}."
      end
    end

    private

    def call_for_booth_params
      params.require(:call_for_booth).permit(:start_date, :end_date, :booth_limit)
    end
  end
end
