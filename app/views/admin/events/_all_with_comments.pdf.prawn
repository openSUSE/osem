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
  pdf.move_down 10
  pdf.table events_array, header: true, cell_style: {size: 8, border_width: 1, position: :center},column_widths: [40,60,90,50,70,65,85,50,55,50,60,45]
  pdf.start_new_page
  pdf.text "#{@conference.short_title} Comments", font_size: 25, align: :center
  pdf.move_down 20
  @events.each do |event|
    if event.root_comments.any?
      if event.time.present?
        pdf.text "<b>#{event.title} by #{event.speaker_names} on #{event.time.strftime("%m/%d/%Y")}  at #{event.time.strftime("%I:%M%p")} </b> ", inline_format: true
      else
        pdf.text "<b>#{event.title} by #{event.speaker_names} </b>", inline_format: true
      end
      pdf.move_down 5
      event.root_comments.each do |comment|
        pdf.text " <i>#{comment.created_at.strftime("%Y-%m-%d")} #{comment.created_at.strftime("%I:%M%p")} </i> <b>#{comment.user.name}:</b> #{comment.body}", font_size: 10, style: :normal, inline_format: true, align: :justify
        pdf.move_down 3
      end
      pdf.move_down 20
    end
  end
end
