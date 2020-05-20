# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id }

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  delegate :name, to: :user

  private

  def conference_id
    event.program.conference_id
  end
end
