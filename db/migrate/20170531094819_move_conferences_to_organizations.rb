class MoveConferencesToOrganizations < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempOrganization < ActiveRecord::Base
    self.table_name = 'organizations'
  end

  def change
    add_reference :conferences, :organization, index: true
    add_foreign_key :conferences, :organizations, dependent: :delete

    TempConference.reset_column_information
    organization = TempOrganization.create(name: 'organization', description: 'Default organization to migrate old conferences to the new version of OSEM')
    TempConference.all.each do |conference|
      conference.organization_id = organization.id
      conference.save!
    end
  end
end
