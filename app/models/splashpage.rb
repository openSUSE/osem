# frozen_string_literal: true

# == Schema Information
#
# Table name: splashpages
#
#  id                        :bigint           not null, primary key
#  banner_photo_content_type :string
#  banner_photo_file_name    :string
#  banner_photo_file_size    :integer
#  banner_photo_updated_at   :datetime
#  include_booths            :boolean
#  include_cfp               :boolean          default(FALSE)
#  include_lodgings          :boolean
#  include_program           :boolean
#  include_registrations     :boolean
#  include_social_media      :boolean
#  include_sponsors          :boolean
#  include_tickets           :boolean
#  include_tracks            :boolean
#  include_venue             :boolean
#  public                    :boolean
#  shuffle_highlights        :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  conference_id             :integer
#
class Splashpage < ApplicationRecord
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }
end
