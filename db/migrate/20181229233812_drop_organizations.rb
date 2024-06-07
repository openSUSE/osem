class DropOrganizations < ActiveRecord::Migration[7.0]
  def change
    drop_table :organizations do |t|
      t.string :name, null: false
      t.text :description
      t.string :picture
    end

    remove_reference :conferences, :organization, index: true
  end
end
