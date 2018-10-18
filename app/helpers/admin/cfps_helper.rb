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
  end
end
