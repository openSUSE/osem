# frozen_string_literal: true

class AddLanguagesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :languages, :string
  end
end
