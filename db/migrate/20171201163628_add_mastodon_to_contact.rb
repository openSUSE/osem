# frozen_string_literal: true

class AddMastodonToContact < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :mastodon, :string
  end
end
