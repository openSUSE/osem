# frozen_string_literal: true

require 'spec_helper'

describe OrganizationsController do
  let!(:organization) { create(:organization) }
  let!(:conference) do
    create(
      :conference,
      splashpage:   create(:splashpage, public: true),
      venue:        create(:venue),
      organization: organization
    )
  end
  let!(:antiquated_conference) do
    create(
      :conference,
      splashpage:   create(:splashpage, public: true),
      venue:        create(:venue),
      organization: organization,
      start_date:   2.weeks.ago,
      end_date:     1.week.ago
    )
  end

  let!(:other_conference) { create(:conference) }
  let!(:user) { create(:user) }

  describe 'GET #index' do
    before :each do
      sign_in user
      get :index
    end

    it { expect(response).to render_template('index') }
  end

  describe 'GET #conferences' do
    before :each do
      get :conferences, params: { id: organization.id }
    end

    it 'loads the organization' do
      expect(assigns(:organization)).to eq organization
    end

    it 'includes organization conferences' do
      expect(assigns(:current)).to include conference
    end

    it 'does not include conferences outside organization' do
      expect(assigns(:current)).not_to include other_conference
      expect(assigns(:antiquated)).not_to include other_conference
    end

    it 'includes antiquated organization conferences' do
      expect(assigns(:antiquated)).to include antiquated_conference
    end
  end
end
