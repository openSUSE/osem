class AddMastodonToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :mastodon, :string
  end
end
