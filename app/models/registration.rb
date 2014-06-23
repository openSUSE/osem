class Registration < ActiveRecord::Base
  belongs_to :user
  belongs_to :conference
  belongs_to :dietary_choice

  has_one :supporter_registration
  has_one :supporter_level, :through => :supporter_registration
  has_and_belongs_to_many :social_events
  has_and_belongs_to_many :events
  has_and_belongs_to_many :qanswers
  has_and_belongs_to_many :vchoices

  attr_accessible :user_id, :conference_id, :attending_social_events, :attending_with_partner,
                  :using_affiliated_lodging, :arrival, :departure, :user_attributes, :other_dietary_choice, :dietary_choice_id,
                  :handicapped_access_required, :supporter_registration_attributes, :social_event_ids, :other_special_needs,
                  :event_ids, :attended, :volunteer, :vchoice_ids,
                  :qanswer_ids, :qanswers_attributes

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :supporter_registration
  accepts_nested_attributes_for :social_events
  accepts_nested_attributes_for :qanswers

  delegate :name, :to => :user
  delegate :email, :to => :user
  delegate :nickname, :to => :user
  delegate :affiliation, :to => :user
  
  alias_attribute :other_needs, :other_special_needs

  after_create :set_week

  def week
    created_at.strftime('%W').to_i
  end

  private

  def set_week
    self.week = created_at.strftime('%W')
    save!
  end
end
