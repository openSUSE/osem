# frozen_string_literal: true

class AddPictures < ActiveRecord::Migration
  def change
    add_column :conferences, :picture, :string
    add_column :lodgings, :picture, :string
    add_column :sponsors, :picture, :string
    add_column :venues, :picture, :string
  end
end
