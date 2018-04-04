# frozen_string_literal: true

class Vday < ApplicationRecord
  belongs_to :conference

  has_many :vchoices
  has_many :vpositions, through: :vchoices, dependent: :destroy
end
