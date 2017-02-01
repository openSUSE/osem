class AddDomainToConferences < ActiveRecord::Migration
  def change
  	add_column :conferences, :domain, :string
  	add_index :conferences, [:domain]
  end
end
