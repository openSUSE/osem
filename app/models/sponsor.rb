class Sponsor < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :sponsorship_level
  belongs_to :conference

  serialize :swags, Hash
  attr_accessor :type, :quantity, :swag_index, :hint_hash

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :unconfirmed, -> { where(state: 'uncofirmed') }

  state_machine initial: :uncofirmed do
    state :uncofirmed
    state :confirmed


    event :confirm do
      transitions to: :confirmed, from: [:uncofirmed]
    end

    event :cancel do
      transitions to: :uncofirmed, from: [:confirmed]
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
