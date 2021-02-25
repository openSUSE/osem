# frozen_string_literal: true

# == Schema Information
#
# Table name: question_types
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#
class QuestionType < ApplicationRecord
  has_many :questions
end
