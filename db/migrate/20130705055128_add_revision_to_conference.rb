# frozen_string_literal: true

class AddRevisionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :revision, :integer
  end
end
