# frozen_string_literal: true

module BootstrapMacros
  # Interact with Bootstrap Switch
  def switch(locator, to:, **options)
    checkbox = find(:checkbox, locator, **options, visible: :hidden)

    checkbox.ancestor('.bootstrap-switch').click unless checkbox.checked? == to
    expect(page).to have_selector(:checkbox, locator, **options, visible: :hidden, checked: to)
  end
end
