# frozen_string_literal: true

class CreateSurveySubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_submissions do |t|
      t.integer :user_id
      t.integer :survey_id

      t.timestamps null: false
    end
  end
end
