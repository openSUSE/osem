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

describe Room do
  subject { create(:room) }

  describe 'validation' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:venue_id) }
    it { should validate_numericality_of(:size).only_integer.is_greater_than(0).allow_nil }
  end

  describe 'association' do
    it { should belong_to(:venue) }
    it { should have_many(:event_schedules).dependent(:destroy) }
    it { should have_many(:tracks) }
  end

  describe 'callback' do
    after { subject.run_callbacks(:create) }

    it '#generate_guid' do
      regex_base64 = %r{^(?:[A-Za-z_\-0-9+\/]{4}\n?)*(?:[A-Za-z_\-0-9+\/]{2}|[A-Za-z_\-0-9+\/]{3}=)?$}
      expect(subject).to receive(:generate_guid)
      expect(subject.guid).to match regex_base64
    end
  end
end
