# frozen_string_literal: true

class EventUser < ApplicationRecord
  # TODO: Do we need these roles?
  ROLES = [%w[Speaker speaker], %w[Submitter submitter], %w[Moderator moderator]]

  belongs_to :event, touch: true
  belongs_to :user
end
