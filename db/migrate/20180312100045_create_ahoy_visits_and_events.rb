# frozen_string_literal: true

class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :visits, :visit_token, :string
    add_column :visits, :visitor_token, :string

    add_index :visits, [:visit_token], unique: true
    add_index :ahoy_events, [:name, :time]
  end
end
