module RegistrationHelper
  def generate_supporter_level_js(conference)
    str = ""
    conference.supporter_levels.map do |t|
      next if t.url.empty?

      str += "if ($('#registration_supporter_registration_attributes_supporter_level_id option:selected').text() == '#{t.title}') {\n"
      str += "console.log('#{t.title}');\n"
      str += "str = 'If you have a confirmation or registration code, enter it here.  Otherwise, you can purchase a <i>#{t.title}</i> ticket <a href=\"#{t.url}\" target=_new>here</a>, if you need to.';\n"
      str += "}\n\n"
    end.join("\n")
    str
  end
end