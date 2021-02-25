# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id                 :bigint           not null, primary key
#  booth_limit        :integer          default(0)
#  color              :string
#  custom_css         :text
#  custom_domain      :string
#  description        :text
#  end_date           :date             not null
#  end_hour           :integer          default(20)
#  events_per_week    :text
#  guid               :string           not null
#  logo_file_name     :string
#  picture            :string
#  registration_limit :integer          default(0)
#  revision           :integer          default(0), not null
#  short_title        :string           not null
#  start_date         :date             not null
#  start_hour         :integer          default(9)
#  ticket_layout      :integer          default("portrait")
#  timezone           :string           not null
#  title              :string           not null
#  use_vdays          :boolean          default(FALSE)
#  use_volunteers     :boolean
#  use_vpositions     :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  organization_id    :integer
#
# Indexes
#
#  index_conferences_on_organization_id  (organization_id)
#
require 'spec_helper'

describe ConferenceSerializer, type: :serializer do
  let(:conference) do
    create(:conference, short_title: 'goto',
                        description: 'Lorem ipsum dolor sit',
                        start_date:  Date.new(2014, 03, 04),
                        end_date:    Date.new(2014, 03, 10))
  end

  let(:serializer) { ConferenceSerializer.new(conference) }

  context 'when the conference does not have rooms and tracks' do
    it 'correctly serializes the conference' do
      expect(serializer.to_json).to match_response_schema('conference')
    end
  end

  context 'when the conference has rooms and tracks' do
    let(:venue) { create(:venue, conference: conference) }
    let!(:room) { create(:room, venue: venue) }
    let!(:track) { create(:track, program: conference.program) }

    it 'correctly serializes the conference' do
      expect(serializer.to_json).to match_response_schema('conference')
    end
  end
end
