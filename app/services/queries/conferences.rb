class Queries::Conferences
  def initialize(conference: nil)
    @conference = conference
  end

  def self.conference_by_filter(conference_finder_conditions)
    Conference.unscoped.eager_load(
      :splashpage,
      :program,
      :registration_period,
      :contact,
      venue: :commercial
    ).find_by!(conference_finder_conditions)
  end

  def sponsorship_levels
    conference.sponsorship_levels.eager_load(
      :sponsors
    ).order('sponsorship_levels.position ASC', 'sponsors.name')
  end
  
  def confirmed_tracks
    conference.confirmed_tracks.eager_load(
      :room
    ).order('tracks.name')
  end

  private

  attr :conference
end

