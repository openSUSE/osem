# frozen_string_literal: true

class TrackType < ApplicationRecord
  belongs_to :program, touch: true

  has_paper_trail meta:   { conference_id: :conference_id },
                  ignore: %i[updated_at]

  validates :title, presence: true

  private

  def conference_id
    program.conference_id
  end
end
