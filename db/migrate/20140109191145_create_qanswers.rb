# frozen_string_literal: true

class CreateQanswers < ActiveRecord::Migration[4.2]
  def change
    create_table :qanswers do |t|
      t.references :question
      t.references :answer
    end
  end
end
