# frozen_string_literal: true

require 'spec_helper'

describe TicketPdf do
  let(:registration_ticket) { create(:registration_ticket, price_cents: 0) }
  let(:conference) do
    create(
      :conference,
      title:               'ExampleCon',
      tickets:             [registration_ticket],
      registration_period: create(:registration_period, start_date: 3.days.ago)
    )
  end
  let(:participant) { create(:user) }
  let(:ticket_purchase) do
    create(
      :ticket_purchase,
      user:       participant,
      conference: conference,
      ticket:     registration_ticket,
      quantity:   1
    )
  end
  let(:physical_ticket) do
    create(:physical_ticket, ticket_purchase: ticket_purchase)
  end
  let(:layout) { conference.ticket_layout.to_sym }
  let(:file_name) { "ticket_for_#{conference.short_title}.pdf" }

  it 'generates a PDF for a physical ticket' do
    pdf = described_class.new(conference, participant, physical_ticket, layout, file_name)
    page_analysis = PDF::Inspector::Page.analyze(pdf.render)
    expect(page_analysis.pages.length).to eq(1)
    expect(page_analysis.pages.first[:strings]).to include(conference.title)
  end

  it 'handles bad logo urls' do
    allow(conference).to receive(:picture?).and_return(true)
    allow(conference).to receive(:picture) do
      double('picture', ticket: double('ticket', url: 'http://broken/link.png'))
    end
    stub_request(:get, 'http://broken/link.png')
      .with(
        headers: {
          'Accept'          => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'      => 'Ruby'
        })
      .to_return(status: 404, body: '', headers: {})

    pdf = described_class.new(conference, participant, physical_ticket, layout, file_name)
    expect{ PDF::Inspector::Page.analyze(pdf.render) }.to_not raise_error
  end
end
