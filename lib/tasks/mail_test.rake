# frozen_string_literal: true

namespace :mail do
  desc 'Test SMTP configuration by sending a test email'
  task test: :environment do
    # Set mail-specific debugging
    original_log_level = Rails.logger.level

    # Enable verbose SMTP debugging
    ActionMailer::Base.logger = Logger.new(STDOUT)
    ActionMailer::Base.logger.level = Logger::DEBUG

    # Enable SMTP protocol debugging - this will show actual SMTP commands
    # Override the delivery method temporarily to enable debugging
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = Rails.application.config.action_mailer.smtp_settings.dup

    # Monkey patch Net::SMTP to enable debugging
    require 'net/smtp'

    # Create a custom logger for SMTP debugging
    smtp_debug_logger = Logger.new(STDOUT)
    smtp_debug_logger.level = Logger::DEBUG

    # Enable Net::SMTP debugging by setting debug_output
    original_new = Net::SMTP.method(:new)
    Net::SMTP.define_singleton_method(:new) do |address, port = nil|
      smtp = original_new.call(address, port)
      smtp.set_debug_output(STDOUT)
      smtp
    end

    puts "=" * 50
    puts "TESTING SMTP CONFIGURATION"
    puts "=" * 50

    # Display current SMTP settings (without password)
    smtp_settings = Rails.application.config.action_mailer.smtp_settings.dup
    smtp_settings[:password] = '[HIDDEN]' if smtp_settings[:password]
    puts "SMTP Settings:"
    smtp_settings.each do |key, value|
      puts "  #{key}: #{value.inspect}"
    end
    puts

    # Get test email addresses
    from_email = ENV.fetch('OSEM_EMAIL_ADDRESS', 'noreply@example.com')
    to_email = ENV['TEST_EMAIL_TO'] || from_email

    puts "Sending test email..."
    puts "From: #{from_email}"
    puts "To: #{to_email}"
    puts "Subject: OSEM SMTP Test - #{Time.current}"
    puts

    begin
      # Create and send test email
      ActionMailer::Base.mail(
        from: from_email,
        to: to_email,
        subject: "OSEM SMTP Test - #{Time.current}",
        body: <<~BODY
          This is a test email from OSEM to verify SMTP configuration.

          Configuration details:
          - Server: #{smtp_settings[:address]}:#{smtp_settings[:port]}
          - Authentication: #{smtp_settings[:authentication]}
          - STARTTLS: #{smtp_settings[:enable_starttls_auto]}
          - Domain: #{smtp_settings[:domain]}

          Sent at: #{Time.current}

          If you receive this email, your SMTP configuration is working correctly!
        BODY
      ).deliver_now

      puts "✅ Email sent successfully!"
      puts "Check your inbox at: #{to_email}"

    rescue => e
      puts "❌ Error sending email:"
      puts "#{e.class}: #{e.message}"
      puts
      puts "Backtrace:"
      puts e.backtrace.first(10).map { |line| "  #{line}" }

      # Provide troubleshooting hints
      puts
      puts "Troubleshooting hints:"
      puts "- Check your .env.production file has correct SMTP settings"
      puts "- Verify OSEM_EMAIL_ADDRESS is set to a valid email"
      puts "- Test your SMTP credentials independently"
      puts "- Check firewall/network connectivity to SMTP server"

    ensure
      # Restore original log level for other components
      Rails.logger.level = original_log_level
    end

    puts
    puts "=" * 50
    puts "SMTP TEST COMPLETED"
    puts "=" * 50
  end

  desc 'Show current mail configuration without sending email'
  task config: :environment do
    puts "=" * 50
    puts "CURRENT MAIL CONFIGURATION"
    puts "=" * 50

    smtp_settings = Rails.application.config.action_mailer.smtp_settings.dup
    smtp_settings[:password] = '[HIDDEN]' if smtp_settings[:password]

    puts "ActionMailer delivery method: #{ActionMailer::Base.delivery_method}"
    puts "Default URL options: #{Rails.application.config.action_mailer.default_url_options}"
    puts
    puts "SMTP Settings:"
    smtp_settings.each do |key, value|
      puts "  #{key}: #{value.inspect}"
    end

    puts
    puts "Environment variables:"
    %w[
      OSEM_EMAIL_ADDRESS OSEM_HOSTNAME OSEM_SMTP_ADDRESS OSEM_SMTP_PORT
      OSEM_SMTP_USERNAME OSEM_SMTP_AUTHENTICATION OSEM_SMTP_DOMAIN
      OSEM_SMTP_ENABLE_STARTTLS_AUTO OSEM_SMTP_OPENSSL_VERIFY_MODE
    ].each do |var|
      value = ENV[var]
      value = '[HIDDEN]' if var.include?('PASSWORD') && value
      puts "  #{var}: #{value || '[NOT SET]'}"
    end
  end
end
