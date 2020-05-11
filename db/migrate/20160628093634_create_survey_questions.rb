# frozen_string_literal: true

class CreateSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_questions do |t|
      t.references :survey
      t.string :title
      t.integer :kind, default: 0
      t.integer :min_choices
      t.integer :max_choices
      t.text :possible_answers
      t.boolean :mandatory, default: false
    end
  end
end
