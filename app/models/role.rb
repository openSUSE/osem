class Role < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  has_and_belongs_to_many :users, join_table: :users_roles

  scopify

  validates :name, presence: true

  validates :name, uniqueness: { scope: :resource }
end
