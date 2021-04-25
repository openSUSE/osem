# frozen_string_literal: true

require 'spec_helper'

describe FullCalendarFormatter do
  let!(:room0) { create(:room) }
  let!(:room1) { create(:room) }

  describe 'JSON formatting for FullCalendar' do
    it 'translates rooms to resources' do
      room_list = [room1, room2] # TODO
    end
  end
end
