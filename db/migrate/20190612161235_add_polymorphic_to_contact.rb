class AddPolymorphicToContact < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :contactable_type, :string
    add_column :contacts, :contactable_id, :integer
  end
end
