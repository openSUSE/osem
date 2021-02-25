# frozen_string_literal: true

# == Schema Information
#
# Table name: difficulty_levels
#
#  id          :bigint           not null, primary key
#  color       :string
#  description :text
#  title       :string
#  created_at  :datetime
#  updated_at  :datetime
#  program_id  :integer
#
class DifficultyLevel < ApplicationRecord
  belongs_to :program, touch: true
  has_many :events, dependent: :nullify

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :title, presence: true

  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color

  private

  def capitalize_color
    self.color = color.upcase if color.present?
  end

  def conference_id
    program.conference_id
  end
end
