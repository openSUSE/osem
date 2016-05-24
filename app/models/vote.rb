class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  delegate :name, to: :user

  private

  def conference_id
    event.program.conference_id
  end
end
