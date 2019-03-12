# frozen_string_literal: true

class ChangeVisitIdTypeOfAhoyEventsToInteger < ActiveRecord::Migration[5.0]
  def change
    adapter_type = connection.adapter_name.downcase.to_sym
    
    case adapter_type
    when :postgresql
      change_column :ahoy_events, :visit_id, :integer, limit: nil, using: "('x' || translate(left(visit_id::text, 18), '-', ''))::bit(32)::int"
    else
      change_column :ahoy_events, :visit_id, :integer, limit: nil
    end

    
  end
end
