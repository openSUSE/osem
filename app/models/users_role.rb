# frozen_string_literal: true

class UsersRole < ApplicationRecord
  belongs_to :role
  belongs_to :user

  has_paper_trail on: [:create, :destroy], meta: { conference_id: :conference_id }

  private

  def conference_id
    role.resource_id
  end
end
