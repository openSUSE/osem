class AddSponsorDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :sponsor_description, :text
  end
end
