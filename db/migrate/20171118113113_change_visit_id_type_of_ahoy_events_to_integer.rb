# frozen_string_literal: true

class ChangeVisitIdTypeOfAhoyEventsToInteger < ActiveRecord::Migration[5.0]
  def change
    change_column :ahoy_events, :visit_id, :integer, limit: nil
  end
end
