# frozen_string_literal: true

class RemoveSocialEventsTable < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'

    has_many :temp_social_events
  end

  class TempSocialEvent < ActiveRecord::Base
    self.table_name = 'social_events'

    belongs_to :temp_conference
    has_and_belongs_to_many :temp_registrations
  end

  class TempRegistration < ActiveRecord::Base
    self.table_name = 'registrations'

    belongs_to :temp_conference
    has_and_belongs_to_many :temp_social_events
    has_and_belongs_to_many :temp_qanswers
  end

  class TempRegistrationsSocialEvent < ActiveRecord::Base
    self.table_name = 'registrations_social_events'

    belongs_to :temp_registrations
    belongs_to :temp_social_events
  end

  class TempQuestionType < ActiveRecord::Base
    self.table_name = 'question_types'

    has_many :temp_questions
  end

  class TempQuestion < ActiveRecord::Base
    self.table_name = 'questions'

    has_many :temp_qanswers
    has_many :temp_answers, through: :temp_qanswers
    belongs_to :temp_question_type
    has_and_belongs_to_many :temp_conferences
  end

  class TempAnswer < ActiveRecord::Base
    self.table_name = 'answers'

    has_many :temp_qanswers
    has_many :temp_questions, through: :temp_qanswers
  end

  class TempQanswer < ActiveRecord::Base
    self.table_name = 'qanswers'

    belongs_to :temp_question
    belongs_to :temp_answer
    has_and_belongs_to_many :temp_registrations
  end

  class TempConferencesQuestions < ActiveRecord::Base
    self.table_name = 'conferences_questions'
  end

  class TempQanswerRegistration < ActiveRecord::Base
    self.table_name = 'qanswers_registrations'
  end

  def up
    # Create Question of 'Multiple Choice' type
    qtype = TempQuestionType.find_or_create_by!(title: 'Multiple Choice')

    TempConference.all.each do |conference|
      if TempSocialEvent.where(conference_id: conference.id).any?
        # Find existing question or initialize it
        question = TempQuestion.find_or_initialize_by(title:            'Which of the following social events are you going to attend?',
                                                      conference_id:    conference.id,
                                                      question_type_id: qtype.id)
        question.save!
        # Enable the question for the conference
        TempConferencesQuestions.find_or_create_by!(conference_id: conference.id,
                                                    question_id:   question.id)
      end

      TempSocialEvent.where(conference_id: conference.id).each do |social_event|
        answer = TempAnswer.find_or_create_by!(title: social_event.title)
        # Associate answer with the question
        qa = TempQanswer.find_or_initialize_by(question_id: question.id,
                                               answer_id:   answer.id)
        qa.save!

        # Associate appropriate answer with registration
        TempRegistrationsSocialEvent.where(social_event_id: social_event.id).each do |registration_social_event|
          registration = TempRegistration.find(registration_social_event.registration_id)
          TempQanswerRegistration.find_or_create_by!(registration_id: registration.id,
                                                     qanswer_id:      qa.id)
        end
      end
    end

    drop_table :social_events
    drop_table :registrations_social_events
  end

  def down
    create_table :social_events do |t|
      t.references :conference
      t.string :title
      t.text :description
      t.date :date
    end

    create_table :registrations_social_events, id: false do |t|
      t.references :registration, :social_event
    end

    qtype = TempQuestionType.find_by(title: 'Multiple Choice')

    TempConference.all.each do |conference|
      if qtype && (question = TempQuestion.find_by(title: 'Which of the following social events are you going to attend?',
                                                   conference_id: conference.id, question_type_id: qtype.id))
        TempQanswer.where(question_id: question.id).each do |qa|
          TempQanswerRegistration.where(qanswer_id: qa.id).each do |qa_registration|
            answer = TempAnswer.find(qa.answer_id)
            registration = TempRegistration.find(qa_registration.registration_id)
            social_event = TempSocialEvent.find_or_create_by!(title:         answer.title,
                                                              conference_id: conference.id)
            TempRegistrationsSocialEvent.find_or_create_by!(registration_id: registration.id,
                                                            social_event_id: social_event.id)
          end
        end
      end
    end
  end
end
