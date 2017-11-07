prawn_document(force_download: true, filename: "#{@file_name}.pdf", page_layout: :landscape) do |pdf|
  events_array = []
  header_array = ['Event ID',
                  'Title',
                  'Abstract',
                  'Start time',
                  'Submitter',
                  'Speaker',
                  'Speaker Email',
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
    row << (event.time.present? ? "#{event.time.strftime("%Y-%m-%d")} #{event.time.strftime("%I:%M%p")} " : '')
    row << event.submitter.name
    row << event.speaker_names
    row << event.speaker_emails
    row << event.event_type.title
    row << (event.track.present? ? event.track.name : '')
    row << (event.difficulty_level.present? ? event.difficulty_level.title : '')
    row << (event.room.present? ? event.room.name : '')
    row << event.state
    events_array << row
  end

  pdf.text "#{@conference.short_title} Events", font_size: 25, align: :center
  pdf.table events_array, header: true, cell_style: {size: 8, border_width: 1},column_widths: [40,60,90,50,70,65,85,50,55,50,60,45]
end
