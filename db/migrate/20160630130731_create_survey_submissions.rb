class CreateSurveySubmissions < ActiveRecord::Migration
  def change
    create_table :survey_submissions do |t|
      t.integer :user_id
      t.integer :survey_id

      t.timestamps null: false
    end
  end
end
