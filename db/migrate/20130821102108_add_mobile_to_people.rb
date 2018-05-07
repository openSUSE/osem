# frozen_string_literal: true

class AddMobileToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mobile, :string
  end
end
