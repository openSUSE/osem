# frozen_string_literal: true

module RevisionCount
  extend ActiveSupport::Concern

  included do
    after_update :increment_revision
  end

  def increment_revision
    conference.update_column(:revision, conference.revision + 1)
  end
end
