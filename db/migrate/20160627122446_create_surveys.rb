class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :title
      t.text :description
      t.references :surveyable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
