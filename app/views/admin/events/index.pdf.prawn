prawn_document(force_download: true, filename: @pdf_filename, page_layout: :landscape) do |pdf|
  events_array = []
  c_array = []
  header_array = ['Event ID',
                  'Title',
                  'Abstract',
                  'Start time',
                  'Submitter',
                  'Speaker',
                  'Event Type',
                  'Track',
                  'Difficulty Level',
                  'Room',
                  'State'
                 ]
  events_array << header_array
  @events.each do |event|
    row = []
    row << event.id
    row << event.title
    row << event.abstract
    row << event.time.to_s
    row << event.submitter.name
    row << event.speaker_names
    row << event.event_type.title
    row << (event.track.present? ? event.track.name : '')
    row << (event.difficulty_level.present? ? event.difficulty_level.title : '')
    row << (event.room.present? ? event.room.name : '')
    row << event.state
    events_array << row
  end

  comments_array = []
  header_array = ['Comment ID',
                  'Event Title',
                  'Body',
                  'User name']
  comments_array << header_array
  @events.each do |event|
    event.root_comments.each do |comment|
      row = []
      row << comment.id
      row << event.title
      row << comment.body
      row << comment.user.name
      comments_array << row
    end
  end

  pdf.text "#{@conference.short_title} Events", font_size: 25
  pdf.table events_array, header: true, cell_style: {size: 5, border_width: 1}
  pdf.move_down 10
  pdf.text "#{@conference.short_title} Comments", font_size: 25
  pdf.table comments_array, header: true, cell_style: {size: 5, border_width: 1}
end
