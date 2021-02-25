# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  blog          :string
#  email         :string
#  facebook      :string
#  googleplus    :string
#  instagram     :string
#  mastodon      :string
#  social_tag    :string
#  sponsor_email :string
#  twitter       :string
#  youtube       :string
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
class Contact < ApplicationRecord
  has_paper_trail on: [:update], ignore: [:updated_at], meta: { conference_id: :conference_id }

  belongs_to :conference

  validates :conference, presence: true
  # Conferences only have one contact
  validates :facebook, :twitter, :googleplus, :instagram, :mastodon,
            format: URI::regexp(%w(http https)), allow_blank: true

  def has_social_media?
    return true if facebook.present? || twitter.present? || googleplus.present? || instagram.present? || mastodon.present? || email.present?

    false
  end
end
