class AddOrganizationToVersions < ActiveRecord::Migration[5.2]
  def up
    add_reference :versions, :organization
    deconflate
  end

  def down
    conflate
    remove_reference :versions, :organization
  end

  private

  def conflate
    say 'conflate'

    PaperTrail::Version.where.not(organization_id: nil).each do |version|
      version.update_attributes conference_id: version.organization_id
    end
  end

  def deconflate
    say 'deconflate'

    PaperTrail::Version.where.not(conference_id: nil).where(item_type: %[Role UsersRole]).each do |version|
      id = version.conference_id

      if Organization.exists?(id)
        raise "version #{version.id} conflates organization #{id} with conference #{id}" if Conference.exists?(id)

        version.update_attributes conference_id: nil, organization_id: id
      end
    end
  end
end
