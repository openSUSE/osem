# frozen_string_literal: true

class AddIncludeBannerInSplashToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :include_banner_in_splash, :boolean, default: false
  end
end
