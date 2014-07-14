class EventAttachment < ActiveRecord::Base
  has_paper_trail

  belongs_to :event
  attr_accessible :public, :attachment, :event_id, :title

  has_attached_file :attachment, :path => ":rails_root/storage/:rails_env/attachments/:id/:style/:basename.:extension"
  include Rails.application.routes.url_helpers
  do_not_validate_attachment_file_type :attachment

  def to_jq_upload
    {
        "name" => read_attribute(:attachment_file_name),
        "size" => read_attribute(:attachment_file_size),
        "title" => read_attribute(:title),
        "public" => read_attribute(:public),
        #"url" => attachment.url(:original),
        "url" => conference_proposal_event_attachment_path(self.event.conference.short_title, self.event_id, self.id),
        "delete_url" => conference_proposal_event_attachment_path(self.event.conference.short_title, self.event_id, self.id),
        "delete_type" => "DELETE"
    }

  end
  #:path => ":rails_root/public/system/:attachment/:id/:style/:filename",
  #    :url => "/system/:attachment/:id/:style/:filename"

  #has_paper_trail :meta => {:associated_id => :event_id, :associated_type => "Event"}


end
