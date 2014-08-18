class QuestionType < ActiveRecord::Base
  attr_accessible :title, :description

  has_many :questions
end
