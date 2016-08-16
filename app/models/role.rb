class Role < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  has_many :users_roles
  has_many :users, through: :users_roles

  has_paper_trail on: [:create, :update], only: [:name, :description], meta: { conference_id: :resource_id }

  before_destroy :cancel
  scopify

  validates :name, presence: true

  validates :name, uniqueness: { scope: :resource }

  private

  # Needed to ensure that removing all user from role doesn't remove role.
  def cancel
    false
  end
end
