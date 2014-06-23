prawn_document(:force_download=>true, :filename => @pdf_filename) do |pdf|
  table_array = []
  header_array = ["   ",
                  "Name",
                  "Email",
                  "Attending Social Events",
                  "Attending With Partner",
                  "Arrival Date",
                  "Departure Date"]
  table_array << header_array
  @registrations.each do |registration|
    row = []
    row << ""
    row << registration.name
    row << registration.email
    if registration.attending_social_events
      row << "X"
    else
      row << " "
    end

    if registration.attending_with_partner.to_s
      row << "X"
    else
      row << " "
    end
    row << registration.arrival.to_s
    row << registration.departure.to_s
    table_array << row
  end

  pdf.text "#{@conference.title} Registrations", :font_size => 25
  pdf.table table_array, :header => true, :cell_style => {:size => 5, :border_width => 1}
end
