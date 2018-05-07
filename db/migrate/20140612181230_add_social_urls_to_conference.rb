# frozen_string_literal: true

class AddSocialUrlsToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :twitter_url, :string
    add_column :conferences, :facebook_url, :string
    add_column :conferences, :google_url, :string
  end
end
