class CreateSurveyReplies < ActiveRecord::Migration
  def change
    create_table :survey_replies do |t|
      t.integer :survey_question_id
      t.integer :user_id
      t.text :text

      t.timestamps null: false
    end
  end
end
