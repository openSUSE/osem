# frozen_string_literal: true

class AddPictures < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :picture, :string
    add_column :lodgings, :picture, :string
    add_column :sponsors, :picture, :string
    add_column :venues, :picture, :string
  end
end
