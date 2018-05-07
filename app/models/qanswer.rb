# frozen_string_literal: true

class Qanswer < ApplicationRecord
  belongs_to :question
  belongs_to :answer, dependent: :delete

  has_and_belongs_to_many :registrations

  validates :question, :answer, presence: true
end
