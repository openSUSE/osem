# frozen_string_literal: true

class AddCustomDomainToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :custom_domain, :string
  end
end
