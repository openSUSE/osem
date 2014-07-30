class EventAttachmentsController < ApplicationController
  load_and_authorize_resource :conference, find_by: :short_title
  load_and_authorize_resource :proposal, class: Event
  load_and_authorize_resource :upload, class: EventAttachment, through: :proposal
  before_filter :verify_user
  skip_before_filter :verify_user, only: [:show]

  def index
    @uploads = @proposal.event_attachments
    @uploads = @uploads.map{|upload| upload.to_jq_upload }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uploads.to_json}
    end
  end

  def show

    if @upload.public?
      send_file @upload.attachment.path
      return
    end

    if current_user.nil?
      verify_user
      return
    end

    if organizer_or_admin? || current_user == upload.event.submitter
      send_file @upload.attachment.path
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def new
    @upload = EventAttachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @upload }
    end
  end

  def edit
  end

  def create
    params[:event_attachment][:title] = params[:title][0]
    params[:event_attachment][:public] = false
    params[:event_attachment][:event_id] = params[:proposal_id]

    if cannot? :create, EventAttachment
      begin
        current_user.events.find(params[:proposal_id])
      rescue
        # They certainly aren't allowed to attach a file to someone else's proposal
        raise ActionController::RoutingError.new('Invalid proposal')
      end
    end

    if params.has_key?(:public)
      params[:event_attachment][:public] = true
    end
    @upload = EventAttachment.new(params[:event_attachment])

    respond_to do |format|
      if @upload.save
        format.html {
          render json: [@upload.to_jq_upload].to_json,
                 content_type: 'text/html',
                 layout: false
        }
        format.json do
          render json: [@upload.to_jq_upload].to_json, status: :created,
                 location: conference_proposal_event_attachment_path(@upload.event.conference.short_title, @upload.event, @upload)
        end
      else
        format.html { render action: "new" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

    if can? :destroy, @proposal
      @upload = @proposal.event_attachments.find(params[:id])
    end

    @upload.destroy if !@upload.nil?

    respond_to do |format|

      format.html { redirect_back_or_to conference_proposal_index_path(@conference.short_title), notice: "Deleted successfully attachment '#{@upload.title}' for proposal '#{@proposal.title}'" }

      format.json { head :no_content }
    end
  end
end
