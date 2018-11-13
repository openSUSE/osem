class AddYoutubeAndBlogToContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :youtube, :string
    add_column :contacts, :blog, :string
  end
end
