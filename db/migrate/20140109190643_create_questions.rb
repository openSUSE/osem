# frozen_string_literal: true

class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.references :question_type
      t.integer :conference_id
      t.boolean :global

      t.timestamps
    end
  end
end
