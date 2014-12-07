class AddIsKeynoteToEventTypes < ActiveRecord::Migration
  def change
    add_column :event_types, :is_keynote, :boolean, default: false
  end
end
