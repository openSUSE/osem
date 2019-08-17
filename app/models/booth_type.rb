# frozen_string_literal: true

class BoothType < ApplicationRecord
  belongs_to :program, touch: true
  has_many :booths, dependent: :restrict_with_error

  has_paper_trail meta:   { conference_id: :conference_id },
                  ignore: %i[updated_at]

  validates :title, presence: true

  private

  def conference_id
    program.conference_id
  end
end
