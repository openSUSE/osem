# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id       :bigint           not null, primary key
#  guid     :string           not null
#  name     :string           not null
#  order    :integer
#  size     :integer
#  url      :string
#  venue_id :integer          not null
#
require 'spec_helper'
describe RoomSerializer, type: :serializer do
  let(:room) { create(:room) }
  let(:serializer) { RoomSerializer.new(room) }

  it 'set guid, name and description' do
    expected_json = {
      guid:        room.guid,
      name:        room.name,
      description: ''
    }.to_json

    expect(serializer.to_json).to eq expected_json
  end
end
