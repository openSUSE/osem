class SponsorshipLevel < ActiveRecord::Base
  validates :title, presence: true
  belongs_to :conference
  acts_as_list scope: :conference
  has_many :sponsors

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }
end
