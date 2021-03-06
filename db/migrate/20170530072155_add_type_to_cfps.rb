# frozen_string_literal: true

class AddTypeToCfps < ActiveRecord::Migration[4.2]
  class TmpCfp < ActiveRecord::Base
    self.table_name = 'cfps'
  end

  def change
    add_column :cfps, :cfp_type, :string

    TmpCfp.reset_column_information
    TmpCfp.find_each do |cfp|
      cfp.cfp_type = 'events'
      cfp.save!
    end
  end
end
