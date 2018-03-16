class AddCodeOfConductToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :code_of_conduct, :text
  end
end
