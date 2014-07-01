class AddInstagramUrlToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :instagram_url, :string
  end
end
