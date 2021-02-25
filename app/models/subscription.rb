# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#  user_id       :integer
#
class Subscription < ApplicationRecord
  belongs_to :conference
  belongs_to :user

  has_paper_trail on: %i(create destroy), ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :user_id, uniqueness: { scope: :conference_id, message: 'already subscribed!' }
end
