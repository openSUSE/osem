class AddCodeOfConductToConference < ActiveRecord::Migration[7.0]
  def change
    add_column :conferences, :code_of_conduct, :text
  end
end
