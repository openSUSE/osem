# frozen_string_literal: true

class AddUseVolunteersToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :use_volunteers, :boolean
  end
end
