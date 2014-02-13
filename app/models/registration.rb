class Registration < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
  belongs_to :dietary_choice

  has_one :supporter_registration
  has_one :supporter_level, :through => :supporter_registration
  has_and_belongs_to_many :social_events
  has_and_belongs_to_many :events
  has_and_belongs_to_many :qanswers

  attr_accessible :person_id, :conference_id, :attending_social_events, :attending_with_partner,
                  :using_affiliated_lodging, :arrival, :departure, :person_attributes, :other_dietary_choice, :dietary_choice_id,
                  :handicapped_access_required, :supporter_registration_attributes, :social_event_ids, :other_special_needs, :event_ids, :attended, :qanswer_ids, :qanswers_attributes

  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :supporter_registration
  accepts_nested_attributes_for :social_events
  accepts_nested_attributes_for :qanswers

  delegate :first_name, :to => :person
  delegate :last_name, :to => :person
  delegate :public_name, :to => :person
  delegate :email, :to => :person
  delegate :irc_nickname, :to => :person
  delegate :company, :to => :person
  
  alias_attribute :other_needs, :other_special_needs
end
