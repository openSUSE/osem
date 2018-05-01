# frozen_string_literal: true

class AddPersonAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :email_public, :boolean
    add_column :users, :biography, :text
    add_column :users, :nickname, :string
    add_column :users, :affiliation, :string
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_updated_at, :datetime
  end
end
