# frozen_string_literal: true

class RemoveUnusedLogoColumnsFromSponsors < ActiveRecord::Migration
  def up
    remove_column :sponsors, :logo_updated_at
    remove_column :sponsors, :logo_file_size
    remove_column :sponsors, :logo_content_type
  end

  def down
    add_column :sponsors, :logo_updated_at, :datetime
    add_column :sponsors, :logo_file_size, :integer
    add_column :sponsors, :logo_content_type, :string
  end
end
