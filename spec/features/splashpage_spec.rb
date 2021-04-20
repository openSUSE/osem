# frozen_string_literal: true

require 'spec_helper'

feature Splashpage do

  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:participant) { create(:user, biography: '', is_admin: false) }

  scenario 'create a valid splashpage', js: true do
    sign_in organizer
    visit admin_conference_splashpage_path(conference.short_title)

    click_link 'Create Splashpage'
    click_button 'Save Changes'
    page.find('#flash')
    expect(flash).to eq('Splashpage successfully created.')
    expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
    expect(page.has_text?('Private')).to be true
  end

  context 'splashpage already created' do
    let!(:splashpage) { create(:splashpage, conference: conference, public: false)}

    scenario 'update a valid splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)

      click_link 'Edit'
      check('Make splash page public')
      click_button 'Save Changes'
      page.find('#flash')
      expect(flash).to eq('Splashpage successfully updated.')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
      expect(page.has_text?('Public')).to be true

      click_link 'Edit'
      expect(page.has_checked_field?('Make splash page public?')).to be true
    end

    scenario 'delete the splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)
      click_link 'Delete'
      page.accept_alert
      page.find('#flash')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
      expect(flash).to eq('Splashpage was successfully destroyed.')
      expect(Splashpage.count).to eq(0)
    end

    scenario 'splashpage is accessible for organizers if it is not public' do
      sign_in organizer
      visit conference_path(conference.short_title)
      expect(current_path).to eq(conference_path(conference.short_title))
    end

    scenario 'splashpage is not accessible for participants if it is not public' do
      sign_in participant
      visit conference_path(conference.short_title)
      page.find('#flash')
      expect(flash).to eq('You are not authorized to access this page.')
      expect(current_path).to eq(root_path)
    end
  end

  context 'navigation' do
    let!(:splashpage) { create(:splashpage, conference: conference, public: true)}

    context 'multiple organizations' do
      let!(:additional_organization) { create(:organization) }

      scenario 'should have organization logo', feature: true, js: true do
        sign_in participant
        visit conference_path(conference.short_title)

        expect(find('.navbar-brand img')['alt']).to have_content conference.organization.name
      end
    end
  end

  context 'happening now section', feature: true, js: true do
    let!(:conference2) { create(:full_conference, start_date: 1.day.ago, end_date: 7.days.from_now, start_hour: 0, end_hour: 24) }
    let!(:program) { conference2.program }
    let!(:selected_schedule) { create(:schedule, program: program) }
    let!(:splashpage) { create(:full_splashpage, conference: conference2, public: true)}

    let!(:scheduled_event1) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed', abstract: '`markdown`')
    end
    let!(:scheduled_event2) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:scheduled_event3) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:scheduled_event4) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:current_time) { Time.now.in_time_zone(conference2.timezone) }
    before :each do
      sign_in participant
    end

    scenario 'displays \'There are no events scheduled yet.\' if nothing is happening now and next' do
      visit conference_path(conference2.short_title)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content('There are no events scheduled yet.')
    end

    scenario 'shows all events happening next if nothing is happening now' do
      event_schedule1 = create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule2 = create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      visit conference_path(conference2.short_title)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content(event_schedule1.event.title)
      expect(happening_now).to have_content(event_schedule2.event.title)
    end

    scenario 'only shows all events happening now if something is happening now and next' do
      event_schedule1 = create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule2 = create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule3 = create(:event_schedule, event: scheduled_event3, schedule: selected_schedule, start_time: current_time.strftime('%a, %d %b %Y %H:%M:%S'))
      visit conference_path(conference2.short_title)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content(event_schedule3.event.title)
      expect(happening_now).not_to have_content(event_schedule1.event.title)
      expect(happening_now).not_to have_content(event_schedule2.event.title)
    end

    scenario 'only shows events happening at the earliest time, not at a later time in the future' do
      event_schedule1 = create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule2 = create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule3 = create(:event_schedule, event: scheduled_event3, schedule: selected_schedule, start_time: (current_time + 2.hours).strftime('%a, %d %b %Y %H:%M:%S'))
      visit conference_path(conference2.short_title)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content(event_schedule1.event.title)
      expect(happening_now).to have_content(event_schedule2.event.title)
      expect(happening_now).not_to have_content(event_schedule3.event.title)
    end

    scenario 'only shows 3 events happening now because of pagination' do
      event_schedule1 = create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: current_time.strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule2 = create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: current_time.strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule3 = create(:event_schedule, event: scheduled_event3, schedule: selected_schedule, start_time: current_time.strftime('%a, %d %b %Y %H:%M:%S'))
      event_schedule4 = create(:event_schedule, event: scheduled_event4, schedule: selected_schedule, start_time: current_time.strftime('%a, %d %b %Y %H:%M:%S'))

      visit conference_path(conference2.short_title)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content(event_schedule1.event.title)
      expect(happening_now).to have_content(event_schedule2.event.title)
      expect(happening_now).to have_content(event_schedule3.event.title)
      expect(happening_now).not_to have_content(event_schedule4.event.title)

      visit conference_path(conference2.short_title, page: 2)
      happening_now = page.find('#happening-now')
      expect(happening_now).to have_content(event_schedule4.event.title)
    end
  end
end
