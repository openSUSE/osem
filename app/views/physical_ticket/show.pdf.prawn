prawn_document(filename: @file_name, page_layout: :portrait, :page_size =>'A4' ) do |pdf|
  # Vertical Layout
  top = pdf.bounds.top
  bottom = pdf.bounds.bottom
  left = pdf.bounds.left
  right = pdf.bounds.right
  mid_vertical = (pdf.bounds.top-pdf.bounds.bottom)/2
  mid_horizontal = (pdf.bounds.right-pdf.bounds.left)/2
  x = 0

  pdf.move_down mid_vertical
  pdf.dash(2, :space => 1)
  pdf.stroke_horizontal_rule
  pdf.stroke_vertical_line pdf.bounds.top, pdf.bounds.bottom, :at => mid_horizontal
  pdf.move_up mid_vertical
  pdf.draw_text "TICKET HOLDER", :at => [x,pdf.cursor-30], :size => 17
  pdf.dash(2, :space => 0)
  pdf.stroke_rectangle  [x, pdf.cursor-50], 230, 150
  pdf.move_down 80
  pdf.draw_text "NAME", :at => [x+10,pdf.cursor], :size => 13
  pdf.fill_color "808080"
  pdf.draw_text "#{@user.name}", :at => [x+10,pdf.cursor-25], size: 20
  pdf.fill_color "000000"
  pdf.draw_text "EMAIL", :at => [x+10,pdf.cursor-50], :size => 13
  pdf.fill_color "808080"
  pdf.draw_text "#{@user.email}", :at => [x+10,pdf.cursor-75], size: 20
  pdf.fill_color "000000"
  pdf.move_up 20
  if @conference.picture?
    if 7 * @conference.picture.image[:width] > 12 * @conference.picture.image[:height]
      pdf.image "#{Rails.root}/public#{@conference.picture_url}", :at => [mid_horizontal+30, pdf.cursor], :width => 120
    else
      pdf.image "#{Rails.root}/public#{@conference.picture_url}", :at => [mid_horizontal+30, pdf.cursor], :height => 70
    end
  else
    pdf.image "#{Rails.root}/public/img/osem-logo.png", :at => [mid_horizontal+30, pdf.cursor], :height => 70
  end
  pdf.move_down 70
  pdf.draw_text "#{@conference.title}", :at => [mid_horizontal+30,pdf.cursor-30], :size => 12
  pdf.draw_text "#{@conference.organization.name}", :at => [mid_horizontal+30,pdf.cursor-50], :size => 12
  pdf.draw_text "#{@conference.venue.name}", :at => [mid_horizontal+30,pdf.cursor-70]
  pdf.move_up 130
  pdf.move_down mid_vertical
  pdf.draw_text "EVENT", :at => [x,pdf.cursor-40], :size => 15
  pdf.fill_color "808080"
  pdf.draw_text "#{@conference.title}", :at => [x,pdf.cursor-60], size: 12
  pdf.draw_text "#{@conference.start_date.strftime('%B %d, %Y')}", :at => [x,pdf.cursor-80], size: 12
  pdf.move_down 80
  pdf.fill_color "000000"
  pdf.draw_text "TICKET", :at => [x,pdf.cursor-30], :size => 15
  pdf.fill_color "808080"
  pdf.draw_text "#{@physical_ticket.ticket.title}", :at => [x,pdf.cursor-50], size: 12
  pdf.move_down 50
  pdf.fill_color "000000"
  pdf.draw_text "TICKET REF.", :at => [x,pdf.cursor-30], :size => 15
  pdf.fill_color "808080"
  pdf.draw_text "#{@physical_ticket.ticket_purchase.id}", :at => [x,pdf.cursor-50], size: 12
  pdf.move_down 50
  pdf.fill_color "000000"
  pdf.draw_text "Powered By OSEM", :at => [(mid_horizontal-left-100)/2,pdf.cursor-100], :size => 11
  pdf.move_up 180
end
