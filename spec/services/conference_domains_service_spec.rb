require 'spec_helper'

describe ConferenceDomainsService do
  let!(:conference) { create(:conference, custom_domain: 'demo.osem.io') }
  subject { ConferenceDomainsService.new(conference: conference) }

  describe 'return correct value' do
    before do
      ENV['OSEM_HOSTNAME'] = 'osem-demo.herokuapp.com'
    end

    it 'returns true if cname record matches the domain name' do
      expect(subject.check_custom_domain).to eq true
    end

    it 'returns feature disabled if OSEM_HOSTNAME is not present' do
      ENV['OSEM_HOSTNAME'] = nil

      expect(subject.check_custom_domain).to eq '--feature disabled--'
    end

    it 'returns false if cname record is not present' do
      conference.update_attribute(:custom_domain, 'osem-demo.herokuapp.com')

      expect(subject.check_custom_domain).to eq false
    end
  end
end
