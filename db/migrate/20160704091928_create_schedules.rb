class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.belongs_to :program, index: true
      t.timestamps null: false
    end
    add_column :programs, :selected_schedule, :integer # Selected schedule ID
  end
end
