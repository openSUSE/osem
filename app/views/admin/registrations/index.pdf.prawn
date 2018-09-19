prawn_document(force_download: true, filename: @pdf_filename, page_layout: :landscape) do |pdf|
  table_array = []
  header_array = ['Attended',
                  'Name',
                  'Nickname',
                  'Affiliation',
                  'Email',
                  'Arrival Date',
                  'Departure Date']
  @conference.questions.each do |question|
    header_array << question.title
  end

  table_array << header_array
  @registrations.each do |registration|
    row = []
    row << ( registration.attended ? 'X' : '' )
    row << registration.name
    row << registration.nickname
    row << registration.affiliation
    row << registration.email
    row << registration.arrival.to_s || ''
    row << registration.departure.to_s || ''

    @conference.questions.each do |question|
      qa = registration.qanswers.find{|qa| qa.question_id == question.id }
      row << ( qa ? qa.answer.title : '' )
    end

    table_array << row
  end

  pdf.text "#{@conference.title} Registrations", font_size: 25
  pdf.table table_array, header: true, cell_style: {size: 5, border_width: 1}
end
