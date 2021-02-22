# frozen_string_literal: true

# == Schema Information
#
# Table name: users_roles
#
#  id      :bigint           not null, primary key
#  role_id :integer
#  user_id :integer
#
# Indexes
#
#  index_users_roles_on_user_id_and_role_id  (user_id,role_id)
#
class UsersRole < ApplicationRecord
  belongs_to :role
  belongs_to :user

  delegate :conference_id, :organization_id, to: :role

  has_paper_trail on:   [:create, :destroy],
                  meta: { conference_id: :conference_id, organization_id: :organization_id }
end
