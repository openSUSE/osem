# frozen_string_literal: true

class AddTshirtToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :tshirt, :string
  end
end
