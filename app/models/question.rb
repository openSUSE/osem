class Question < ActiveRecord::Base
  attr_accessible :title, :global, :answers_attributes, :answer_ids, :question_type_id
  
  belongs_to :question_type
  has_and_belongs_to_many :conferences
  
  has_many :qanswers, dependent: :delete_all
  has_many :answers, through: :qanswers, dependent: :delete_all
  
  validates :title, presence: true
  validates :answers, presence: true
  
  accepts_nested_attributes_for :answers, allow_destroy: true
end
