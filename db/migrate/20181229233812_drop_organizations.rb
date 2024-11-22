class DropOrganizations < ActiveRecord::Migration[7.0]
  def change
    remove_reference :conferences, :organization, index: true

    drop_table :organizations do |t|
      t.string :name, null: false
      t.text :description
      t.string :picture
    end
  end
end
