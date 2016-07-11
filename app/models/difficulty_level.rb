class DifficultyLevel < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  validates :title, presence: true
  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color

  private

  def capitalize_color
    self.color = color.upcase if color.present?
  end
end
