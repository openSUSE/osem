# frozen_string_literal: true

# Allow webdriver update urls
# from https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
allowed_urls = Webdrivers::Common.subclasses.map(&:base_url)
allowed_urls << /geckodriver/
# We've seen [a redirect](https://github.com/titusfortner/webdrivers/issues/204) to this domain
allowed_urls += ['github-releases.githubusercontent.com']

# Allow stripe.com for stripe integration tests
allowed_urls += ['stripe.com']

WebMock.disable_net_connect!(allow_localhost: true, allow: allowed_urls)
