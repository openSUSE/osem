# frozen_string_literal: true

class AddLogoToConferencesTable < ActiveRecord::Migration
  def change
    add_column :conferences, :logo_file_name, :string
    add_column :conferences, :logo_content_type, :string
    add_column :conferences, :logo_file_size, :integer
    add_column :conferences, :logo_updated_at, :datetime
  end
end
