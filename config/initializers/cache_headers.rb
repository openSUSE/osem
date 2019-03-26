# Set cache headers
Rails.application.config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=31536000' }
