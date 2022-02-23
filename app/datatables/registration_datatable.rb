# frozen_string_literal: true

class RegistrationDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegator :@view, :edit_admin_conference_registration_path

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:                       { source: 'Registration.id', cond: :eq },
      name:                     { source: 'User.name' },
      roles:                    { source: 'Role.name' },
      email:                    { source: 'User.email' },
      accepted_code_of_conduct: { source: 'Registration.accepted_code_of_conduct', searchable: false },
      actions:                  { source: 'Registration.id', searchable: false, orderable: false }
    }
  end

  private

  def conference
    @conference ||= options[:conference]
  end

  def conference_role_titles(record)
    record.roles.collect do |role|
      role.name.titleize if role.resource == conference
    end.compact
  end

  def data
    records.map do |record|
      {
        id:                       record.id,
        name:                     record.user.name,
        roles:                    conference_role_titles(record.user),
        email:                    record.email,
        accepted_code_of_conduct: !!record.accepted_code_of_conduct, # rubocop:disable Style/DoubleNegation
        questions:                {},
        edit_url:                 edit_admin_conference_registration_path(conference, record),
        DT_RowId:                 record.id
      }
    end
  end

  def get_raw_records # rubocop:disable Naming/AccessorMethodName
    conference.registrations.includes(user: :roles).references(:users, :roles).distinct
  end

  # override upstream santitation, which converts everything to strings
  def sanitize(records)
    records
  end
end
