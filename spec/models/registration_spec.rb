#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe 'Registration' do

  let!(:user) { create(:user) }
  let!(:conference) { create(:conference) }
  let!(:registration1) { create(:registration, conference: conference, user: user) }
  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:registration)).to be_valid
    end

    describe 'registration_limit_not_exceed' do
      it 'is not valid when limit exceeded' do
        conference.registration_limit = 1
        expect { create(:registration, conference: conference, user: user) }.to raise_error
        expect(user.registrations.size).to be 1
      end
    end
  end

  describe '#destroy_purchased_tickets' do
    it 'destroys purchased tickets if tickets are purchased' do
      create(:ticket_purchase, conference: conference, user: user)
      expect(user.registrations.size).to be 1
      expect(user.ticket_purchases.size).to be 1
      registration1.destroy
      expect(user.registrations.size).to be 0
      expect(user.ticket_purchases.size).to be 0
    end
    it 'destroys no tickets if no tickets are purchased' do
      expect(user.registrations.size).to be 1
      expect(user.ticket_purchases.size).to be 0
      registration1.destroy
      expect(user.registrations.size).to be 0
      expect(user.ticket_purchases.size).to be 0
    end
  end
end
