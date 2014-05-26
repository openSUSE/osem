class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
    	t.string :title
    	t.string :email_id
    	t.text :description
    	t.string :photo_file_name
    	t.string :photo_content_type
    	t.integer :photo_file_size
    	t.datetime :photo_updated_at
      t.timestamps
    end
  end
end
