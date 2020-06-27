# frozen_string_literal: true

class AddIncludeBoothsToSplashpages < ActiveRecord::Migration[4.2]
  def change
    add_column :splashpages, :include_booths, :boolean
  end
end
