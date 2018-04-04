# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :title

      t.timestamps
    end
  end
end
