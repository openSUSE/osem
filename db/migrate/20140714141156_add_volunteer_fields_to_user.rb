# frozen_string_literal: true

class AddVolunteerFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :mobile, :string
    add_column :users, :tshirt, :string
    add_column :users, :languages, :string
    add_column :users, :volunteer_experience, :text
  end
end
