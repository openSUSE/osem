# frozen_string_literal: true

class AddSocialUrlsToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :twitter_url, :string
    add_column :conferences, :facebook_url, :string
    add_column :conferences, :google_url, :string
  end
end
