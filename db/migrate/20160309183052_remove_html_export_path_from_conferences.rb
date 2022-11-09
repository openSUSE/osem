# frozen_string_literal: true

class RemoveHtmlExportPathFromConferences < ActiveRecord::Migration[4.2]
  def change
    remove_column :conferences, :html_export_path, :string
  end
end
