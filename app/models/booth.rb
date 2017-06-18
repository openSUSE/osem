class Booth < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :conference
  has_many :booth_requests
  has_many :users, through: :booth_requests

  validates :title,
            uniqueness: { case_sensitive: false },
            presence: true

  validates :description,
            :reasoning,
            :state,
            :logo_link,
            :conference_id,
            presence: true

  state_machine initial: :submitted do
    state :submitted
    state :withdrawn
    state :to_accept
    state :accepted
    state :rejected

    event :restart do
      transitions to: :submitted, from: [:withdrawn]
    end
    event :withdrawn do
      transitions to: :withdrawn, from: [:submitted, :to_accept, :accepted]
    end
    event :to_accept do
      transitions to: :to_accept, from: [:submitted, :rejected, :accepted]
    end
    event :accept do
      transitions to: :accepted, from: [:submitted, :to_accept]
    end
    event :reject do
      transitions to: :rejected, from: [:submitted]
    end
    event :reset do
      transitions to: :submitted, from: [:to_accept]
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
