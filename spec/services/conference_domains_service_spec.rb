require 'spec_helper'

describe ConferenceDomainsService do
  let(:conference) { create(:conference, custom_domain: 'demo.osem.io') }
  let(:resolver) { double('resolver') }
  let(:service) { ConferenceDomainsService.new(conference, resolver) }

  describe '#check_custom_domain' do
    subject { service.check_custom_domain }
    let(:cname_record) { double(name: cname_domain) }

    before do
      ENV['OSEM_HOSTNAME'] = 'osem-demo.herokuapp.com'
      allow(resolver).to receive(:getresource).with(conference.custom_domain, Resolv::DNS::Resource::IN::CNAME)
        .and_return(cname_record)
    end

    context 'when the cname record matches the domain name' do
      let(:cname_domain) { ENV['OSEM_HOSTNAME'] }
      it { is_expected.to eq true }
    end

    context 'when the cname record does not match the domain name' do
      let(:cname_domain) { 'random.domain.com' }
      it { is_expected.to eq false }
    end

    context 'when there is no cname record present' do
      let(:cname_record) { nil }
      it { is_expected.to eq false }
    end
  end
end
