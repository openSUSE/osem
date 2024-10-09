# frozen_string_literal: true

class UpdateEventStates < ActiveRecord::Migration[4.2]
  def change
    execute "UPDATE events SET state='new' WHERE state = 'review';"
  end
end
