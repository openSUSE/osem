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
#  include_happening_now     :boolean
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

FactoryBot.define do
  factory :splashpage do

    public  { false }

    factory :full_splashpage do

      public { true }

      include_tracks { true }
      include_program { true }
      include_social_media { true }
      include_venue { true }
      include_tickets { true }
      include_registrations { true }
      include_sponsors { true }
      include_lodgings { true }
      include_cfp { true }
      include_happening_now { true }
    end
  end
end
