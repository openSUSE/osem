class AddLanguagesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :languages, :string
  end
end
