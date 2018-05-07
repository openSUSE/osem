# frozen_string_literal: true

class AddUrlToCommercial < ActiveRecord::Migration
  class TempCommercial < ActiveRecord::Base
    self.table_name = 'commercials'
  end

  def change
    add_column :commercials, :url, :string

    # Don't delete commercial_type and commercial_id for backward compatibility
  end
end
