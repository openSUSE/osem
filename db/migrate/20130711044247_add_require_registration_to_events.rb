# frozen_string_literal: true

class AddRequireRegistrationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :require_registration, :boolean
  end
end
