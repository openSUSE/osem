# frozen_string_literal: true

class QuestionType < ApplicationRecord
  has_many :questions
end
