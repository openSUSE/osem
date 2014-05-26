class CreateSponsorshipRegistrations < ActiveRecord::Migration
  def change
    create_table :sponsorship_registrations do |t|
    	t.string :name
    	t.string :email_id
    	t.string :contact_no
    	t.float :amount_donated
    	t.string :method_of_donation
      t.belongs_to :organization
      t.belongs_to :sponsorship_level
      t.belongs_to :conference
      t.timestamps
    end
  end
end
