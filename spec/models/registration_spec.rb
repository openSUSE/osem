#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe 'Registration' do
  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:registration)).to be_valid
    end

    describe 'registration_limit_not_exceed' do
      it 'is not valid when limit exceeded' do
        conference = build(:conference)
        conference.registration_limit = 1
        registration1 = build(:registration, conference: conference)
        registration1.save
        registration2 = build(:registration, conference: conference)
        registration2.save
        expect(conference.registrations.size).to be 1
        expect(registration2.valid?).to be false
        expect(registration2.errors.full_messages).to eq(['Registration limit exceeded'])
      end
    end
  end
  describe 'after destroy' do
    it 'destroys purchased tickets' do
      conference = build(:conference)
      registration1 = build(:registration, conference: conference)
      registration1.save
      ticket_purchase = build(:ticket_purchase, conference: conference)
      ticket_purchase.save
      expect(conference.ticket_purchases.size).to be 1
      registration1.destroy
      expect(conference.registrations.size).to be 0
      expect(conference.ticket_purchases.size).to be 0
    end
  end
end
