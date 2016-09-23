class VotableField < ActiveRecord::Base
  belongs_to :conference
  validates :title, :votable_type, :stars, presence: true
  validates :title, uniqueness: {scope: :votable_type, message: 'already exsists for the selected votable type'}

  VALID_VOTABLE_TYPES = %w(Event).freeze
  # ratyrate does not allow criterias to have spaces in them
  validate :no_spaces_in_title
  validate :correct_votable_type

  private

  def no_spaces_in_title
    errors.add(:title, 'should not have spaces') unless title.match(/\s/).nil?
  end

  def correct_votable_type
    errors.add(:votable_type, "should be one of the following: #{VALID_VOTABLE_TYPES.join(', ')}") unless VALID_VOTABLE_TYPES.include? votable_type
  end
end
