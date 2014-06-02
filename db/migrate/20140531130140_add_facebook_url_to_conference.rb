class AddFacebookUrlToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :facebook_url, :string
  end
end
