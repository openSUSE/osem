require 'spec_helper'
require 'ahoy'

describe Campaign do
  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:campaign)).to be_valid
    end

    it 'is not valid without a name' do
      should validate_presence_of(:name)
    end
  end

  describe '#url_parameters' do
    it 'returns the parameters in the correct format' do
      campaign = create(:campaign, utm_source: 'google+', utm_medium: 'advertisement',
                                   utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent')
      campaign.conference = create(:conference)

      result = '?utm_source=google+&utm_medium=advertisement&utm_term=opensource&utm_content=content&utm_campaign=20percent'
      expect(campaign.url_parameters).to eq(result)
    end

    it 'returns only utm_campaign parameter if there are no parameters' do
      campaign = create(:campaign)
      campaign.conference = create(:conference)
      expect(campaign.url_parameters).to eq('?utm_campaign=testcampaign')
    end
  end

  describe '#visits' do
    it 'returns one if there is one visit' do
      campaign = create(:campaign, utm_source: 'google+', utm_medium: 'advertisement',
                                   utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent')
      campaign.conference = build(:conference)

      create(:visit, utm_source: 'google+', utm_medium: 'advertisement',
                     utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent', started_at: Time.now + 1.hour)
      expect(campaign.visits_count).to eq(1)
    end

    it 'returns zero if there are no visits' do
      campaign = create(:campaign, utm_source: 'google+', utm_medium: 'advertisement',
                                   utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent')
      campaign.conference = create(:conference)

      expect(campaign.visits_count).to eq(0)
    end
  end

  describe '#registrations' do
    it 'returns zero if there are no registration' do
      campaign = build(:campaign, utm_source: 'google+', utm_medium: 'advertisement',
                                  utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent')
      campaign.conference = build(:conference)

      expect(campaign.registrations_count).to eq(0)
    end
  end

  describe '#submissions' do
    it 'returns zero if there are no submissions' do
      campaign = build(:campaign, utm_source: 'google+', utm_medium: 'advertisement',
                                  utm_term: 'opensource', utm_content: 'content', utm_campaign: '20percent')
      campaign.conference = build(:conference)

      expect(campaign.submissions_count).to eq(0)
    end
  end
end
