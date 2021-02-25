# frozen_string_literal: true

# == Schema Information
#
# Table name: email_settings
#
#  id                                            :bigint           not null, primary key
#  accepted_body                                 :text
#  accepted_subject                              :string
#  booths_acceptance_body                        :text
#  booths_acceptance_subject                     :string
#  booths_rejection_body                         :text
#  booths_rejection_subject                      :string
#  cfp_dates_updated_body                        :text
#  cfp_dates_updated_subject                     :string
#  conference_dates_updated_body                 :text
#  conference_dates_updated_subject              :string
#  conference_registration_dates_updated_body    :text
#  conference_registration_dates_updated_subject :string
#  confirmed_without_registration_body           :text
#  confirmed_without_registration_subject        :string
#  program_schedule_public_body                  :text
#  program_schedule_public_subject               :string
#  registration_body                             :text
#  registration_subject                          :string
#  rejected_body                                 :text
#  rejected_subject                              :string
#  send_on_accepted                              :boolean          default(FALSE)
#  send_on_booths_acceptance                     :boolean          default(FALSE)
#  send_on_booths_rejection                      :boolean          default(FALSE)
#  send_on_cfp_dates_updated                     :boolean          default(FALSE)
#  send_on_conference_dates_updated              :boolean          default(FALSE)
#  send_on_conference_registration_dates_updated :boolean          default(FALSE)
#  send_on_confirmed_without_registration        :boolean          default(FALSE)
#  send_on_program_schedule_public               :boolean          default(FALSE)
#  send_on_registration                          :boolean          default(FALSE)
#  send_on_rejected                              :boolean          default(FALSE)
#  send_on_submitted_proposal                    :boolean          default(FALSE)
#  send_on_venue_updated                         :boolean          default(FALSE)
#  submitted_proposal_body                       :text
#  submitted_proposal_subject                    :string
#  venue_updated_body                            :text
#  venue_updated_subject                         :string
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  conference_id                                 :integer
#

FactoryBot.define do
  factory :email_settings do
    send_on_registration { true }
    send_on_accepted { false }
    send_on_rejected { false }
    send_on_confirmed_without_registration { false }
    send_on_conference_dates_updated { true }
    send_on_conference_registration_dates_updated { true }
    send_on_program_schedule_public { true }
    send_on_cfp_dates_updated { true }
    conference_dates_updated_body { 'Sample Conference\n New Dates: January 17 - 21 2014' }
    conference_dates_updated_subject { 'Conference dates have been updated' }
    conference_registration_dates_updated_subject { 'Conference registration dates have been updated' }
    conference_registration_dates_updated_body { 'Sample Conference\n New Dates: January 17 - 21 2014' }
    send_on_venue_updated { true }
    venue_updated_subject { 'Venue has been updated' }
    venue_updated_body { 'Venue has been Updated to Sample Location' }
    registration_subject { 'Lorem Ipsum Dolsum' }
    registration_body { 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit' }
    cfp_dates_updated_subject { 'Call for Papers dates have been updated' }
    cfp_dates_updated_body { 'Please checkout the new updates to submit your proposal for Sample Conference' }
    program_schedule_public_subject { 'Sample Conference Cfp schedule is Public' }
    program_schedule_public_body { 'Call for Papers schedule is Public.Checkout the link' }
  end
end
