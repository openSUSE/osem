# frozen_string_literal: true

class AddCustomDomainToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :custom_domain, :string
  end
end
