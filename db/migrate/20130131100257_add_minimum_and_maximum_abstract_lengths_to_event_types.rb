# frozen_string_literal: true

class AddMinimumAndMaximumAbstractLengthsToEventTypes < ActiveRecord::Migration
  def change
    add_column :event_types, :minimum_abstract_length, :integer, default: 0
    add_column :event_types, :maximum_abstract_length, :integer, default: 500
  end
end
