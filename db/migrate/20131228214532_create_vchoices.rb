# frozen_string_literal: true

class CreateVchoices < ActiveRecord::Migration
  def change
    create_table :vchoices do |t|
      t.references :vday
      t.references :vposition
    end
  end
end
