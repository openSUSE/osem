# frozen_string_literal: true

class AddUseVolunteersToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :use_volunteers, :boolean
  end
end
