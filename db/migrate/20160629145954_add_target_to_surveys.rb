# frozen_string_literal: true

class AddTargetToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :target, :integer, default: 0
  end
end
