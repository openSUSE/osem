# frozen_string_literal: true

class Role < ApplicationRecord
  belongs_to :resource, polymorphic: true
  has_many :users_roles
  has_many :users, through: :users_roles

  has_paper_trail on:   [:create, :update],
                  only: [:name, :description],
                  meta: { conference_id: :conference_id, organization_id: :organization_id }

  before_destroy :cancel
  scopify

  validates :name, presence: true

  validates :name, uniqueness: { scope: :resource }

  def conference_id
    resource_type == 'Conference' ? resource_id : nil
  end

  def organization_id
    resource_type == 'Organization' ? resource_id : nil
  end

  private

  # Needed to ensure that removing all user from role doesn't remove role.
  def cancel
    throw(:abort)
  end
end
