class AddSponsorEmailToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :sponsor_email, :string
  end
end
