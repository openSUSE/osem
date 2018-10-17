# frozen_string_literal: true

module Admin
  module CfpsHelper
    def cfp_form_url(cfp, conference)
      if cfp.new_record?
        admin_conference_program_cfps_path
      else
        admin_conference_program_cfp_path(conference, cfp)
      end
    end

    def select_cfp_types(cfp, program)
      cfp_types = program.remaining_cfp_types
      cfp_types.unshift(cfp.cfp_type) unless cfp.new_record?
      cfp_types.map { |cfp_type| ["#{cfp_type.capitalize}", cfp_type] }
    end
  end
end
