# frozen_string_literal: true

module BootstrapMacros
  # Interact with Bootstrap Switch
  def switch(locator, to:, **)
    checkbox = find(:checkbox, locator, **, visible: :hidden)

    checkbox.ancestor('.bootstrap-switch').click unless checkbox.checked? == to
    expect(page).to have_selector(:checkbox, locator, **, visible: :hidden, checked: to)
  end
end
