module ProposalHelper
  def generate_abstract_length_js(conference)
    str = ""
    conference.event_types.map do |t|
      str += "if ($('select option:selected').text() == '#{t.title}') {\n"
      str += "str = '#{t.maximum_abstract_length}';\n"
      str += "maxcount = #{t.maximum_abstract_length};\n"
      str += "}\n\n"
    end.join("\n")
    str
  end
end