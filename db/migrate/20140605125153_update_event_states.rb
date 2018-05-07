# frozen_string_literal: true

class UpdateEventStates < ActiveRecord::Migration
  def change
    execute "UPDATE events SET state='new' WHERE state = 'review';"
  end
end
