class Qanswer < ActiveRecord::Base
  attr_accessible :question_id, :answer_id

  belongs_to :question
  belongs_to :answer, :dependent => :delete
  
  has_and_belongs_to_many :registrations
end
