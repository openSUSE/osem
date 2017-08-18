class AddSwagsToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :payed, :boolean, default: false
    add_column :sponsors, :swags, :boolean, default: false
    add_column :sponsors, :swags_received, :boolean
    add_column :sponsors, :company_address, :string
    add_column :sponsors, :vat_registration, :string
    add_column :sponsors, :has_banner, :boolean, default: false
  end
end
