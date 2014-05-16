class EventAttachment < ActiveRecord::Base
  has_paper_trail
  belongs_to :event
  attr_accessible :public, :attachment, :event_id, :title
  has_attached_file :attachment
  validates_attachment_content_type :attachment, content_type: 
    ['text/plain', 'image/jpg', 'image/jpeg','image/pjpeg', 'image/png', 'image/x-png', 'image/gif',
      'application/pdf', 'application/msword','applicationvnd.ms-word', 
      'applicaiton/vnd.openxmlformats-officedocument.wordprocessingm1.document',
      'application/msexcel', 'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/mspowerpoint', 'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'application/vnd.oasis.opendocument.presentation',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  include Rails.application.routes.url_helpers

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
