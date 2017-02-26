prawn_document(force_download: true, filename: @pdf_filename, page_layout: :landscape) do |pdf|
  pdf.text "Registration for #{@conference.title}", font_size: 25
  pdf.text "at #{@conference.venue.name},#{@conference.venue.street},#{@conference.venue.city} / #{@conference.venue.country_name}.", font_size: 12
  pdf.text "Ticket Type: #{}", font_size: 15
  pdf.text "Date: #{}", font_size: 15
  pdf.text "Username: #{@user.username}", font_size: 15
  pdf.text "User Email: #{@user.email}", font_size: 15
  pdf.text "Description: #{}", font_size: 15
  pdf.print_qr_code(@user.username, :extent=>72)
end
