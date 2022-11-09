# frozen_string_literal: true

class AddLanguagesToProgram < ActiveRecord::Migration[4.2]
  def change
    add_column :programs, :languages, :string
  end
end
