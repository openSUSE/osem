# frozen_string_literal: true

class AddConferenceIdToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :conference_id, :integer
  end
end
