# frozen_string_literal: true

class CreateQuestionTypes < ActiveRecord::Migration
  def change
    create_table :question_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
