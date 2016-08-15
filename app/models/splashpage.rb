class Splashpage < ActiveRecord::Base
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }
end
