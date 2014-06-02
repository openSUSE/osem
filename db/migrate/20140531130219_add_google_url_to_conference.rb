class AddGoogleUrlToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :google_url, :string
  end
end
