# frozen_string_literal: true

class AddUseSupporterLevelsToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :use_supporter_levels, :boolean, default: false
  end
end
