class AddUseVpositionsToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :use_vpositions, :boolean
  end
end
