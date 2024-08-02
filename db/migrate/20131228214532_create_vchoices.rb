# frozen_string_literal: true

class CreateVchoices < ActiveRecord::Migration[4.2]
  def change
    create_table :vchoices do |t|
      t.references :vday
      t.references :vposition
    end
  end
end
