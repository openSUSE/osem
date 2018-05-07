# frozen_string_literal: true

class AddDefaultToRevisionInConference < ActiveRecord::Migration
  def change
    change_column :conferences, :revision, :integer, default: 0, null: false
  end
end
