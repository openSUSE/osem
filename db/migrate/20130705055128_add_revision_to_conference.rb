# frozen_string_literal: true

class AddRevisionToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :revision, :integer
  end
end
