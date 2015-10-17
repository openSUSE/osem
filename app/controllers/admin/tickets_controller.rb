module Admin
  class TicketsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :ticket, through: :conference

    def index
      authorize! :update, Ticket.new(conference_id: @conference.id)
    end

    def new
      @ticket = @conference.tickets.new
    end

    def create
      @ticket = @conference.tickets.new(ticket_params)
      if @ticket.save(ticket_params)
        flash[:notice] = 'Ticket successfully created.'
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Creating Ticket failed: #{@ticket.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @ticket.update_attributes(ticket_params)
        flash[:notice] = 'Ticket successfully updated.'
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Ticket update failed: #{@ticket.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @ticket.destroy
        flash[:notice] = 'Ticket successfully destroyed.'
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title)
      else
        flash[:error] = 'Ticket was successfully destroyed.' \
                    "#{@ticket.errors.full_messages.join('. ')}."
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title)
      end
    end

    private

    def ticket_params
      params[:ticket]
    end
  end
end
