# frozen_string_literal: true

# == Schema Information
#
# Table name: booths
#
#  id                     :bigint           not null, primary key
#  description            :text
#  logo_link              :string
#  reasoning              :text
#  state                  :string
#  submitter_relationship :text
#  title                  :string
#  website_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  conference_id          :integer
#
class Booth < ApplicationRecord
  include ActiveRecord::Transitions
  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  belongs_to :conference
  has_many :booth_requests, dependent: :destroy
  has_many :users, through: :booth_requests

  has_one :submitter_booth_user, -> { where(role: 'submitter') }, class_name: 'BoothRequest'
  has_one  :submitter, through: :submitter_booth_user, source: :user

  has_many :responsibles_booth_user, -> { where(role: 'responsible') }, class_name: 'BoothRequest'
  has_many :responsibles, through: :responsibles_booth_user, source: :user

  validates :title,
            uniqueness: { case_sensitive: false },
            presence:   true

  validates :description,
            :reasoning,
            :state,
            :responsibles,
            :conference_id,
            :website_url,
            :submitter_relationship,
            presence: true

  scope :accepted, -> { where(state: 'accepted') }
  scope :confirmed, -> { where(state: 'confirmed') }

  mount_uploader :picture, PictureUploader, mount_on: :logo_link

  state_machine initial: :new do
    state :new
    state :withdrawn
    state :to_accept
    state :accepted
    state :to_reject
    state :rejected
    state :canceled
    state :confirmed

    event :restart do
      transitions to: :new, from: [:withdrawn, :rejected, :canceled]
    end
    event :withdraw do
      transitions to: :withdrawn, from: [:new, :to_accept, :accepted, :to_reject, :rejected, :confirmed]
    end
    event :confirm do
      transitions to: :confirmed, from: [:accepted]
    end
    event :to_accept do
      transitions to: :to_accept, from: [:new, :to_reject]
    end
    event :to_reject do
      transitions to: :to_reject, from: [:new, :to_accept]
    end
    event :accept do
      transitions to: :accepted, from: [:new, :to_accept]
    end
    event :reject do
      transitions to: :rejected, from: [:new, :to_reject]
    end
    event :cancel do
      transitions to: :canceled, from: [:accepted, :rejected, :to_accept, :to_reject, :confirmed]
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end

  def update_state(transition, _notice)
    alert = ''
    begin
      send(transition)
      save
    rescue Transitions::InvalidTransition => e
      alert = "Update state failed. #{e.message}"
    end
    alert
  end
end
