# frozen_string_literal: true

class MoveConferencesToOrganizations < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempOrganization < ActiveRecord::Base
    self.table_name = 'organizations'
  end

  def change
    add_reference :conferences, :organization, index: true

    TempConference.reset_column_information
    if TempConference.count != 0
      organization = TempOrganization.create(name: 'organization', description: 'Default organization')
      TempConference.all.each do |conference|
        conference.organization_id = organization.id
        conference.save!
      end
    end

    add_foreign_key :conferences, :organizations, null: false, on_delete: :cascade
  end
end
