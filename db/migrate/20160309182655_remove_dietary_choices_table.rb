# frozen_string_literal: true

class RemoveDietaryChoicesTable < ActiveRecord::Migration
  class TempDietaryChoice < ApplicationRecord
    self.table_name = 'dietary_choices'

    belongs_to :temp_conference
  end

  class TempConference < ApplicationRecord
    self.table_name = 'conferences'

    has_many :temp_dietary_choices, dependent: :destroy
  end

  class TempRegistration < ApplicationRecord
    self.table_name = 'registrations'

    belongs_to :temp_conference
  end

  class TempQuestionType < ApplicationRecord
    self.table_name = 'question_types'

    has_many :temp_questions
  end

  class TempQuestion < ApplicationRecord
    self.table_name = 'questions'

    has_many :temp_qanswers
    has_many :temp_answers, through: :temp_qanswers
    belongs_to :temp_question_type
    has_and_belongs_to_many :temp_conferences
  end

  class TempAnswer < ApplicationRecord
    self.table_name = 'answers'

    has_many :temp_qanswers
    has_many :temp_questions, through: :temp_qanswers
  end

  class TempQanswer < ApplicationRecord
    self.table_name = 'qanswers'

    belongs_to :temp_question
    belongs_to :temp_answer
    has_and_belongs_to_many :temp_registrations
  end

  class TempConferencesQuestions < ApplicationRecord
    self.table_name = 'conferences_questions'
  end

  class TempQanswerRegistration < ApplicationRecord
    self.table_name = 'qanswers_registrations'
  end

  def up
    # Create Question of 'Multiple Choice' type
    qtype = TempQuestionType.find_or_create_by!(title: 'Single Choice') if TempDietaryChoice.all.any?

    # Migrate dietary_choice_id to a question
    TempConference.all.each do |conference|
      next unless TempDietaryChoice.where(conference_id: conference.id).any?
      # Find existing question or initialize it
      question = TempQuestion.find_or_initialize_by(title: 'Which is your dietary choice?',
                                                    conference_id: conference.id,
                                                    question_type_id: qtype.id)
      question.save!
      # Enable the question for the conference
      TempConferencesQuestions.find_or_create_by!(conference_id: conference.id,
                                                  question_id: question.id)

      TempDietaryChoice.where(conference_id: conference.id).each do |dietary_choice|
        answer = TempAnswer.find_or_create_by!(title: dietary_choice.title)
        # Associate answer with the question
        qa = TempQanswer.find_or_initialize_by(question_id: question.id,
                                               answer_id: answer.id)
        qa.save!

        # Associate appropriate answer with registration
        TempRegistration.where(dietary_choice_id: dietary_choice.id).each do |registration|
          TempQanswerRegistration.find_or_create_by!(registration_id: registration.id,
                                                     qanswer_id: qa.id)
        end
      end
    end

    # Migrate other_dietary_choice to a question and put data in other_special_needs
    TempRegistration.all.each do |registration|
      next if registration.other_dietary_choice.blank?
      conference = TempConference.find(registration.conference_id)
      qtype = TempQuestionType.find_or_create_by!(title: 'Yes/No')
      question = TempQuestion.find_or_initialize_by(title: 'Do you have another dietary choice?',
                                                    conference_id: conference.id,
                                                    question_type_id: qtype.id)
      question.save!
      # Enable the question for the conference
      TempConferencesQuestions.find_or_create_by!(conference_id: conference.id,
                                                  question_id: question.id)

      # Create 'Yes' answer
      answer_yes = TempAnswer.find_or_create_by!(title: 'Yes')

      # Associate answer with the question
      qa = TempQanswer.find_or_initialize_by(question_id: question.id,
                                             answer_id: answer_yes.id)

      qa.save!

      # Associate appropriate answer with registration
      TempQanswerRegistration.find_or_create_by!(registration_id: registration.id,
                                                 qanswer_id: qa.id)

      # Move data from other_dietary_choice to other_special_needs
      registration.other_special_needs << "Other dietary choice: #{registration.other_dietary_choice}."
      registration.save!
    end

    remove_column :conferences, :use_dietary_choices
    remove_column :registrations, :dietary_choice_id
    remove_column :registrations, :other_dietary_choice
    drop_table :dietary_choices
  end

  def down
    create_table :dietary_choices do |t|
      t.references :conference
      t.string :title, null: false
      t.timestamps
    end

    add_column :conferences, :use_dietary_choices, :boolean
    add_column :registrations, :dietary_choice_id, :integer
    add_column :registrations, :other_dietary_choice, :text

    qtype = TempQuestionType.find_by(title: 'Single Choice')
    TempConference.all.each do |conference|
      next unless qtype && (question = TempQuestion.find_by(title: 'Which is your dietary choice?',
                                                            conference_id: conference.id, question_type_id: qtype.id))
      TempQanswer.where(question_id: question.id).each do |qa|
        TempQanswerRegistration.where(qanswer_id: qa.id).each do |qa_registration|
          answer = TempAnswer.find(qa.answer_id)
          registration = TempRegistration.find(qa_registration.registration_id)
          dietary_choice = TempDietaryChoice.find_or_create_by!(title: answer.title,
                                                                conference_id: conference.id)
          registration.dietary_choice_id = dietary_choice.id
          registration.save!
        end
      end
    end

    qtype = TempQuestionType.find_by(title: 'Yes/No')
    answer_yes = TempAnswer.find_by(title: 'Yes')
    TempConference.all.each do |conference|
      next unless qtype && (question = TempQuestion.find_by(title: 'Do you have another dietary choice?',
                                                            conference_id: conference.id, question_type_id: qtype.id))
      TempQanswer.where(question_id: question.id, answer_id: answer_yes.id).each do |qa|
        TempQanswerRegistration.where(qanswer_id: qa.id).each do |qa_registration|
          registration = TempRegistration.find(qa_registration.registration_id)
          registration.other_dietary_choice = 'Yes'
          registration.save!
        end
      end
    end
  end
end
