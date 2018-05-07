# frozen_string_literal: true

class Vposition < ApplicationRecord
  belongs_to :conference

  has_many :vchoices
  has_many :vdays, through: :vchoices

  validates :title, :vdays, presence: true
end
