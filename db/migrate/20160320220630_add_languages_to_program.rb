class AddLanguagesToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :languages, :string
  end
end
