require 'spec_helper'

describe Admin::RegistrationPeriodsController do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }

  let(:organizer) { create(:user, role_ids: organizer_role.id) }
  let(:organizer2) { create(:user, email: 'organizer2@email.osem', role_ids: organizer_role.id) }
  let(:participant) { create(:user) }

  shared_examples 'access as administration or organizer' do

    before do
      conference.registration_period = create(:registration_period)
    end

    describe 'PATCH #update' do

      context 'valid attributes' do

        it 'locates the requested registration period object' do
          patch :update, conference_id: conference.short_title, registration_period: attributes_for(:registration_period)
          expect(assigns(:registration_period)).to eq(conference.registration_period)
        end

        it 'changes registration period attributes' do
          the_date = conference.end_date - 10
          patch :update, conference_id: conference.short_title, registration_period:
              attributes_for(:registration_period, start_date: the_date)

          conference.reload
          expect(conference.registration_period.start_date.to_s).to eq(the_date.to_s)
        end

        it 'redirects to the updated registration period' do
          patch :update, conference_id: conference.short_title, registration_period:
              attributes_for(:registration_period)
          conference.reload
          expect(response).to redirect_to admin_conference_registration_period_path(
                                              conference.short_title)
        end

        it 'sends email notification on conference registration date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          conference.registration_period = create(:registration_period,
                                                  start_date: Date.today,
                                                  end_date: Date.today + 2.days)

          patch :update, conference_id: conference.short_title, registration_period:
              attributes_for(:registration_period,
                             start_date: Date.today + 2.days,
                             end_date: Date.today + 4.days)
          conference.reload
          allow(Mailbot).to receive(:conference_registration_date_update_mail).and_return(mailer)
        end
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the registration period to the database' do
          expected = expect do
            post :create,
                 conference_id: conference.short_title,
                 registration_period: attributes_for(:registration_period)
          end
          expected.to change { RegistrationPeriod.count }.by 1
        end

        it 'redirects to registration_periods#show' do
          post :create,
               conference_id: conference.short_title,
               registration_period: attributes_for(:registration_period)

          expect(response).to redirect_to admin_conference_registration_period_path(
                                              assigns[:conference].short_title)
        end
      end

      context 'with invalid attributes' do
        it 'does not save the registration period to the database' do
          expected = expect do
            post :create,
                 conference_id: conference.short_title,
                 registration_period: attributes_for(:registration_period,
                                                     start_date: nil,
                                                     end_date: nil)
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          post :create,
               conference_id: conference.short_title,
               registration_period: attributes_for(:registration_period,
                                                   start_date: nil,
                                                   end_date: nil)
          expect(response).to be_success
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested registration period to @registration_period' do
        get :edit, conference_id: conference.short_title
        expect(assigns(:registration_period)).to eq conference.registration_period
      end

      it 'renders the show template' do
        get :edit, conference_id: conference.short_title
        expect(response).to render_template :edit
      end
    end

    describe 'GET #show' do
      it 'assigns the requested registration period to @registration_period' do
        get :show, conference_id: conference.short_title
        expect(assigns(:registration_period)).to eq conference.registration_period
      end

      it 'renders the show template' do
        get :show, conference_id: conference.short_title
        expect(response).to render_template :show
      end
    end

    describe 'GET #new' do
      it 'assigns a new registration period to @registration_period' do
        get :new, conference_id: conference.short_title
        expect(assigns(:registration_period)).to be_a_new(RegistrationPeriod)
      end

      it 'renders the :new template' do
        get :new, conference_id: conference.short_title
        expect(response).to render_template :new
      end
    end

    describe 'DELETE #destroy' do
      it 'it deletes the registration period' do
        expect { delete :destroy, conference_id: conference.short_title }.to change(RegistrationPeriod, :count).by(-1)
      end
      it 'redirects to users#show' do
        delete :destroy, conference_id: conference.short_title
        expect(response).to redirect_to admin_conference_registration_period_path
      end
    end
  end

  describe 'organizer access' do

    before(:each) do
      sign_in(organizer)
    end

    it_behaves_like 'access as administration or organizer'

  end
end
