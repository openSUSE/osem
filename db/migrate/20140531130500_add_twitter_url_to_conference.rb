class AddTwitterUrlToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :twitter_url, :string
  end
end
