# frozen_string_literal: true

require 'open-uri'

class TicketPdf < Prawn::Document
  def initialize(conference, user, physical_ticket, ticket_layout, file_name)
    super(page_layout: ticket_layout, page_size: 'A4', filename: file_name)
    @user = user
    @physical_ticket = physical_ticket
    @conference = conference

    @left = bounds.left
    @right = bounds.right
    @mid_vertical = (bounds.top - bounds.bottom) / 2
    @mid_horizontal = (bounds.right - bounds.left) / 2
    @x = 0

    draw_first_square
    draw_second_square
    draw_third_square
    draw_fourth_square
  end

  def draw_first_square
    move_down @mid_vertical
    dash(2, space: 1)
    stroke_horizontal_rule
    stroke_vertical_line bounds.top, bounds.bottom, at: @mid_horizontal
    move_up @mid_vertical
    draw_text 'TICKET HOLDER', at: [@x, cursor - 30], size: 17
    dash(2, space: 0)
    bounding_box [@x, cursor - 50], width: 230, height: 150 do
      pad(15) do
        text_box 'NAME', at: [@x + 10, cursor], size: 13
        fill_color '808080'
        text_box @user.name.to_s, at: [@x + 10, cursor - 20], size: 18
        fill_color '000000'
        text_box 'EMAIL', at: [@x + 10, cursor - 60], size: 13
        fill_color '808080'
        text_box @user.email.to_s, at: [@x + 10, cursor - 80], size: 18, overflow: :shrink_to_fit
        fill_color '000000'
      end
      stroke_bounds
    end
  end

  def draw_second_square
    move_up 150
    if @conference.picture?
      conference_image = case @conference.picture.ticket.url[0, 4]
                         when 'http', 'ftp:' # CDNs
                           begin
                             open(@conference.picture.ticket.url)
                           rescue OpenURI::HTTPError, Errno::ENOENT
                             nil
                           end
                         when '/sys' # local storage
                           open([
                             Rails.root,
                             '/public',
                             @conference.picture.ticket.url
                           ].join)
                         end
    end
    conference_image ||= open("#{Rails.root}/public/img/osem-logo.png")
    image conference_image, at: [@mid_horizontal + 30, cursor], fit: [200, 70]

    move_down 70
    draw_text @conference.title.to_s, at: [@mid_horizontal + 30, cursor - 30], size: 12
    draw_text @conference.organization.name.to_s, at: [@mid_horizontal + 30, cursor - 50], size: 12
    if @conference.venue
      draw_text @conference.venue_name, at: [@mid_horizontal + 30, cursor - 70]
      draw_text @conference.venue_street, at: [@mid_horizontal + 30, cursor - 90]
      draw_text @conference.city, at: [@mid_horizontal + 30, cursor - 110]
    end
    move_up 130
    move_down @mid_vertical
  end

  def draw_third_square
    draw_text 'EVENT', at: [@x, cursor - 40], size: 15
    fill_color '808080'
    draw_text @conference.title.to_s, at: [@x, cursor - 60], size: 12
    draw_text @conference.start_date.strftime('%B %d, %Y').to_s, at: [@x, cursor - 80], size: 12
    move_down 80
    fill_color '000000'
    draw_text 'TICKET', at: [@x, cursor - 30], size: 15
    fill_color '808080'
    draw_text @physical_ticket.ticket.title.to_s, at: [@x, cursor - 50], size: 12
    move_down 50
    fill_color '000000'
    draw_text 'TICKET REF.', at: [@x, cursor - 30], size: 15
    fill_color '808080'
    draw_text @physical_ticket.ticket_purchase.id.to_s, at: [@x, cursor - 50], size: 12
    move_down 50
    fill_color '000000'
    draw_text 'Powered By OSEM', at: [(@mid_horizontal - @left - 100) / 2, cursor - 100], size: 11
    move_up 180
  end

  def draw_fourth_square
    x = @mid_horizontal + (@right - @mid_horizontal - 180) / 2
    y = cursor - (bounds.top - @mid_vertical - 180) / 2
    print_qr_code(@physical_ticket.token, pos: [x, y], extent: 180, stroke: false)
  end
end
