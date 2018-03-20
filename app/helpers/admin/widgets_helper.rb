# frozen_string_literal: true

module Admin
  module WidgetsHelper
    # DRY up rendering of visual elements

    def big_statistic(icon, subtitle, value, delta, reverse_delta = false)
      content_tag('div', class: 'dashbox text-center') do
        content_tag('span', class: 'fa') do
          fa_icon(icon) +
            value.to_s.html_safe # rubocop:disable Rails/OutputSafety
        end +
          content_tag('p') do
            content_tag('small', subtitle.pluralize(value)) +
              '&nbsp;'.html_safe + # rubocop:disable Rails/OutputSafety
              login_delta_label(delta, reverse_delta)
          end
      end
    end

    def login_delta_label(delta, reverse = false)
      variant = if delta.to_i.positive?
                  reverse ? :warning : :success
                elsif delta.to_i.negative?
                  reverse ? :success : :warning
                else
                  :info
                end
      bootstrap_label(
        format('%+d', delta.to_i),
        variant,
        title: "#{delta} since you last logged in"
      )
    end
  end
end
