# frozen_string_literal: true

require 'redcarpet/render_strip'

module FormatHelper
  ##
  # Includes functions related to formatting (like adding classes, colors)
  ##
  def status_icon(object)
    case object.state
    when 'new', 'to_reject', 'to_accept'
      'fa-eye'
    when 'unconfirmed', 'accepted'
      'fa-check text-muted'
    when 'confirmed'
      'fa-check text-success'
    when 'rejected', 'withdrawn', 'canceled'
      'fa-ban'
    end
  end

  def event_progress_color(progress)
    progress = progress.to_i
    if progress == 100
      'progress-bar-success'
    elsif progress >= 85
      'progress-bar-info'
    elsif progress >= 71
      'progress-bar-warning'
    else
      'progress-bar-danger'
    end
  end

  def variant_from_delta(delta, reverse: false)
    if delta.to_i.positive?
      reverse ? 'warning' : 'success'
    elsif delta.to_i.negative?
      reverse ? 'success' : 'warning'
    else
      'info'
    end
  end

  def target_progress_color(progress)
    progress = progress.to_i
    result = case
             when progress >= 90 then 'green'
             when progress < 90 && progress >= 80 then 'orange'
             else 'red'
             end

    result
  end

  def days_left_color(days_left)
    days_left = days_left.to_i
    if days_left > 30
      result = 'green'
    elsif days_left < 30 && days_left > 10
      result = 'orange'
    else
      result = 'red'
    end
    result
  end

  def bootstrap_class_for(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      'alert-warning'
    end
  end

  def label_for(event_state)
    result = ''
    case event_state
    when 'new'
      result = 'label label-primary'
    when 'withdrawn'
      result = 'label label-danger'
    when 'unconfirmed'
      result = 'label label-success'
    when 'confirmed'
      result = 'label label-success'
    when 'rejected'
      result = 'label label-warning'
    when 'canceled'
      result = 'label label-danger'
    end
    result
  end

  def icon_for_todo(bool)
    bool ? 'fa fa-check' : 'fa fa-times'
  end

  def class_for_todo(bool)
    bool ? 'todolist-ok' : 'todolist-missing'
  end

  def word_pluralize(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
             singular
           else
             plural || singular.pluralize
           end

    word
  end

  # Returns black or white deppending on what of them contrast more with the
  # given color. Useful to print text in a coloured background.
  # hexcolor is a hex color of 7 characters, being the first one '#'.
  # Reference: https://24ways.org/2010/calculating-color-contrast
  def contrast_color(hexcolor)
    r = hexcolor[1..2].to_i(16)
    g = hexcolor[3..4].to_i(16)
    b = hexcolor[5..6].to_i(16)
    yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000
    (yiq >= 128) ? 'black' : 'white'
  end

  def td_height(rooms)
    td_height = 500 / rooms.length
    # we want all least 3 lines in events and td padding = 3px, speaker picture height >= 25px
    # and line-height = 17px => (17 * 3) + 6 + 25 = 82
    td_height < 82 ? 82 : td_height
  end

  def room_height(rooms)
    room_lines(rooms) * 17
  end

  def room_lines(rooms)
    # line-height = 17px, td padding = 3px
    (td_height(rooms) - 6) / 17
  end

  def event_height(rooms)
    event_lines(rooms) * 17
  end

  def event_lines(rooms)
    # line-height = 17px, td padding = 3px, speaker picture height >= 25px
    (td_height(rooms) - 31) / 17
  end

  def speaker_height(rooms)
    # td padding = 3px
    speaker_height = td_height(rooms) - 6 - event_height(rooms)
    # The speaker picture is a circle and the width must be <= 37 to avoid making the cell widther
    speaker_height >= 37 ? 37 : speaker_height
  end

  def speaker_width(rooms)
    # speaker picture padding: 4px 2px; and we want the picture to be a circle
    speaker_height(rooms) - 4
  end

  def carousel_item_class(number, carousel_number, num_cols, col)
    item_class = 'item'
    item_class += ' first' if number == 0
    item_class += ' last' if number == (carousel_number - 1)
    if (col && ((col / num_cols) == number)) || (!col && number == 0)
      item_class += ' active'
    end
    item_class
  end

  def selected_scheduled?(schedule)
    (schedule == @selected_schedule) ? 'Yes' : 'No'
  end

  def markdown(text, escape_html=true)
    return '' if text.nil?

    options = {
      autolink: true,
      space_after_headers: true,
      tables: true,
      strikethrough: true,
      footnotes: true,
      superscript: true
    }
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: escape_html), options)
    markdown.render(text).html_safe
  end

  def markdown_hint(text='')
    markdown("#{text} Please look at #{link_to '**Markdown Syntax**', 'https://daringfireball.net/projects/markdown/syntax', target: '_blank'} to format your text", false)
  end

  # Return a plain text markdown stripped of formatting.
  def plain_text(content)
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(content)
  end

  def quantity_left_of(resource)
    return '-/-' if resource.quantity.blank?

    "#{resource.quantity - resource.used}/#{resource.quantity}"
  end
end
