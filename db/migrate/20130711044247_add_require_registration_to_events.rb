class AddRequireRegistrationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :require_registration, :boolean
  end
end
