prawn_document(force_download: true, filename: "#{@file_name}.pdf", page_layout: :landscape) do |pdf|
  tracks_array = []
  header_array = ['Track ID',
                  'Name',
                  'Description',
                  'Room',
                  'Start Date',
                  'End Date',
                  'Submitter Name',
                  'Included in Cfp',
                  'State']
  tracks_array << header_array
  @tracks.each do |track|
    row = []
    row << track.id
    row << track.name.to_s
    row << track.description.to_s
    row << track.try(:room).try(:name)
    row << track.start_date.to_s
    row << track.end_date.to_s
    row << track.try(:submitter).try(:name)
    row << (track.cfp_active? ? 'Yes' : 'No')
    row << track.state
    tracks_array << row
  end
  pdf.text "#{@conference.short_title} tracks", font_size: 25, align: :center
  pdf.table tracks_array, header: true, cell_style: {size: 8, border_width: 1},column_widths: [40,70,230,65,55,55,90,65,50]
end
