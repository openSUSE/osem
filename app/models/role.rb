# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  description   :string
#  name          :string
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#  resource_id   :integer
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#
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
