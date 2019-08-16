class AddAdditionalFieldsToBooths < ActiveRecord::Migration[5.2]
  def change
    add_column :booths, :accepted_code_of_conduct, :boolean
    add_column :booths, :email, :string
    add_column :booths, :special_requirements, :string
  end
end
