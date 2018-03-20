module WidgetsHelper
  # DRY up rendering of visual elements

  # https://getbootstrap.com/docs/3.3/components/#labels
  def bootstrap_label(value, variant, options = {})
    content_tag('span', value, class: "label label-#{variant}", **options)
  end
end
