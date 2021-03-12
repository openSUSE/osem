# frozen_string_literal: true

require 'spec_helper'

describe Mailbot do
  let(:conference) { create(:conference) }
  let!(:email_settings) { create(:email_settings, conference: conference) }
  let(:user) { create(:user, email: 'user@example.com') }

  before { conference.contact.update_attributes(email: 'conf@domain.com') }

  context 'onboarding and proposal' do
    let(:event) { create(:event, program: conference.program, submitter: user) }

    shared_examples 'mailer actions' do
      it 'assigns the email subject' do
        expect(mail.subject).to eq 'Lorem Ipsum Dolsum'
      end

      it 'assigns the email receiver, sender, reply_to' do
        expect(mail.to).to eq ['user@example.com']
        expect(mail.from).to eq ['conf@domain.com']
      end

      it 'assigns the email body' do
        expect(mail.body).to include 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit'
      end

      it 'assigns the email body with the correct color' do
        # p mail.body
        # expect(mail.body).to have_selector('#border.background-color', '#0B3559')
        # Capybara.within_frame(mail.body) do
        #   color = find('#border').native.css_value('background-color')
        #   expect(color).to eq('#0B3559')
        # end

        # TODO: select border ...
        expect(mail.body).to include('background-color: ' + conference.color)
      end

      it 'assigns the email body with the correct logo' do
        expect(mail.body).to include 'snapcon_logo'
      end

      it 'delivers the email' do
        expect(ActionMailer::Base.deliveries).to include(mail)
      end
    end

    describe '.registration_mail' do
      include_examples 'mailer actions' do
        let(:mail) { Mailbot.registration_mail(conference, user).deliver_now }
      end
    end

    describe '.acceptance_mail' do
      before do
        conference.email_settings.update_attributes(send_on_accepted: true,
                                                    accepted_subject: 'Lorem Ipsum Dolsum',
                                                    accepted_body:    'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.acceptance_mail(event).deliver_now }
      end
    end

    describe '.rejection_mail' do
      before do
        conference.email_settings.update_attributes(send_on_rejected: true,
                                                    rejected_subject: 'Lorem Ipsum Dolsum',
                                                    rejected_body:    'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.rejection_mail(event).deliver_now }
      end
    end

    describe '.confirm_reminder_mail' do
      before do
        conference.email_settings.update_attributes(send_on_confirmed_without_registration: true,
                                                    confirmed_without_registration_subject: 'Lorem Ipsum Dolsum',
                                                    confirmed_without_registration_body:    'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.confirm_reminder_mail(event).deliver_now }
      end
    end
  end

  context 'update notifications' do
    it 'is a pending test'
  end

  context 'helper methods' do
    let(:organization) { create(:organization) }
    let(:conference2) { create(:conference, organization: organization) }

    describe '#logo_url' do
      it 'gives the correct logo url' do
        mailbot = Mailbot.new
        expect(mailbot.send(:logo_url, conference2)).to eq('snapcon_logo.png')

        File.open('spec/support/logos/1.png') do |file|
          organization.picture = file
        end

        expect(mailbot.send(:logo_url, conference2)).to include('1.png')

        File.open('spec/support/logos/2.png') do |file|
          conference2.picture = file
        end

        expect(mailbot.send(:logo_url, conference2)).to include('2.png')
      end
    end
  end
end
