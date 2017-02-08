class AddTwitterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter, :string
    add_column :users, :googleplus, :string
    add_column :users, :linkedin, :string
    add_column :users, :gnu, :string
    add_column :users, :diaspora, :string
    add_column :users, :github, :string
    add_column :users, :gitlab, :string
    add_column :users, :gna, :string
    add_column :users, :savannah, :string
    add_column :users, :website_url, :string
  end
end
