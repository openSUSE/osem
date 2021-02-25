# frozen_string_literal: true

# == Schema Information
#
# Table name: tickets
#
#  id                  :bigint           not null, primary key
#  description         :text
#  price_cents         :integer          default(0), not null
#  price_currency      :string           default("USD"), not null
#  registration_ticket :boolean          default(FALSE)
#  title               :string           not null
#  visible             :boolean          default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#  conference_id       :integer
#
FactoryBot.define do
  factory :ticket do
    title { "#{Faker::Hipster.word} Ticket" }
    price_cents { 1000 }
    price_currency { 'USD' }
    visible { true }
    factory :registration_ticket do
      registration_ticket { true }
    end
  end
end
