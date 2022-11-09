# frozen_string_literal: true

class AddUseVpositionsToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :use_vpositions, :boolean
  end
end
