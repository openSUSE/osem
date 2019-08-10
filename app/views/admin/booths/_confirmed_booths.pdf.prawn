prawn_document(force_download: true, filename: "#{@file_name}.pdf", page_layout: :landscape) do |pdf|
  booths_array = []
  header_array = ["#{(t'booth').capitalize } ID",
                  'Title',
                  'Description',
                  'Reasoning',
                  'Submitter Name',
                  'Submitter Relationship',
                  'Website Url',
                  'State']
  booths_array << header_array
  @booths.confirmed.each do |booth|
    row = []
    row << booth.id
    row << booth.title
    row << booth.description
    row << booth.reasoning
    row << booth.submitter.name
    row << booth.submitter_relationship
    row << booth.website_url
    row << booth.state
    booths_array << row
  end
  pdf.text "#{@conference.short_title} booths", font_size: 25, align: :center
  pdf.table booths_array, header: true, cell_style: {size: 8, border_width: 1},column_widths: [45,70,153,152,70,80,105,45]
end
