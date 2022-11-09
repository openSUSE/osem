# frozen_string_literal: true

class AddMobileToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :mobile, :string
  end
end
