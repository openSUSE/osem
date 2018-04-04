# frozen_string_literal: true

class Vchoice < ApplicationRecord
  belongs_to :vday
  belongs_to :vposition

  has_and_belongs_to_many :registrations
end
