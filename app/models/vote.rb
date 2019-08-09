# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  delegate :name, to: :user

  private

  def conference_id
    votable.program.conference_id
  end
end
