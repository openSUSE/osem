# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id                   :bigint           not null, primary key
#  cfp_active           :boolean          not null
#  color                :string
#  description          :text
#  end_date             :date
#  guid                 :string           not null
#  name                 :string           not null
#  relevance            :text
#  short_name           :string           not null
#  start_date           :date
#  state                :string           default("new"), not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#  room_id              :integer
#  selected_schedule_id :integer
#  submitter_id         :integer
#
# Indexes
#
#  index_tracks_on_room_id               (room_id)
#  index_tracks_on_selected_schedule_id  (selected_schedule_id)
#  index_tracks_on_submitter_id          (submitter_id)
#
require 'spec_helper'

describe TrackSerializer, type: :serializer do
  let(:track) { create(:track) }
  let(:serializer) { TrackSerializer.new(track) }

  it 'sets guild, name, color' do
    expected_json = {
      guid:  track.guid,
      name:  track.name,
      color: track.color
    }.to_json

    expect(serializer.to_json).to eq expected_json
  end
end
