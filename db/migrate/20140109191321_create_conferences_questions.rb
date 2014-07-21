class CreateConferencesQuestions < ActiveRecord::Migration
  def change
    create_table :conferences_questions, id: false do |t|
      t.references :conference
      t.references :question
    end
  end
end
