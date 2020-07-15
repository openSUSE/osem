class AddCustomCssToConfereneces < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :custom_css, :text
  end
end
