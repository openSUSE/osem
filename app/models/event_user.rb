# frozen_string_literal: true

# == Schema Information
#
# Table name: event_users
#
#  id         :bigint           not null, primary key
#  comment    :string
#  event_role :string           default("participant"), not null
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#  user_id    :integer
#
class EventUser < ApplicationRecord
  ROLES = [%w[Speaker speaker], %w[Submitter submitter], %w[Moderator moderator],
            %w[Volunteer volunteer]]

  belongs_to :event, touch: true
  belongs_to :user
end
