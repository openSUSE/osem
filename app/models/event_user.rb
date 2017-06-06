class EventUser < ActiveRecord::Base
  # TODO Do we need these roles?
  ROLES = [%w[Speaker speaker], %w[Submitter submitter], %w[Moderator moderator]]

  belongs_to :event
  belongs_to :user
end
