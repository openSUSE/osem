class Role < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  has_and_belongs_to_many :users, join_table: :users_roles
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
