# frozen_string_literal: true

class UsersRole < ApplicationRecord
  belongs_to :role
  belongs_to :user

  delegate :conference_id, :organization_id, to: :role

  has_paper_trail on:   [:create, :destroy],
                  meta: { conference_id: :conference_id, organization_id: :organization_id }
end
