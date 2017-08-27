class Sponsor < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :sponsorship_level
  belongs_to :conference

  serialize :swags, Hash
  serialize :courier_info, Hash

  attr_accessor :type, :quantity, :swag_index, :courier_index,
                :courier_name, :tracking_number, :boxes

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :unconfirmed, -> { where(state: 'unconfirmed') }

  state_machine initial: :unconfirmed do
    state :unconfirmed
    state :confirmed


    event :confirm do
      transitions to: :confirmed, from: [:unconfirmed]
    end

    event :cancel do
      transitions to: :unconfirmed, from: [:confirmed]
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
