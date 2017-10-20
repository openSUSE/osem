class Sponsor < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :sponsorship_level
  belongs_to :conference

  serialize :swag, Hash
  serialize :swag_transportation, Hash
  serialize :responsibe, Hash

  attr_accessor :type, :quantity, :swag_index, :carrier_index,
                :carrier_name, :tracking_number, :boxes,
                :responsible_name, :responsible_email

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :contacted, -> { where(state: 'contacted') }

  state_machine initial: :to_contact do
    state :to_contact
    state :confirmed
    state :contacted

    event :confirm do
      transitions to: :confirmed, from: [:to_contact, :contacted]
    end

    event :cancel do
      transitions to: :to_contact, from: [:confirmed, :contacted]
    end

    event :contact do
      transitions to: :contacted, from: [:to_contact]
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
