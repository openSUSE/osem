# frozen_string_literal: true

class EventUser < ApplicationRecord
  ROLES = [%w[Speaker speaker], %w[Submitter submitter], %w[Moderator moderator],
            %w[Volunteer volunteer]]

  belongs_to :event, touch: true
  belongs_to :user
end
