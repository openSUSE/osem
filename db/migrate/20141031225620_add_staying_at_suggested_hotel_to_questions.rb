class AddStayingAtSuggestedHotelToQuestions < ActiveRecord::Migration
  class TempRegistration < ActiveRecord::Base
    self.table_name = 'registrations'

    belongs_to :temp_conference
  end

  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'

    has_many :temp_registrations
    has_many :temp_questions
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
  end

  class TempConferencesQuestions < ActiveRecord::Base
    self.table_name = 'conferences_questions'
  end

  class TempQanswerRegistration < ActiveRecord::Base
    self.table_name = 'qanswers_registrations'
  end

  def change
    # Create Question of yes/no type
    qtype = TempQuestionType.find_or_create_by!(title: 'Yes/No')
    answer_yes = TempAnswer.find_or_create_by!(title: 'Yes')
    answer_no = TempAnswer.find_or_create_by!(title: 'No')

    # Find existing question or initialize it
    q = TempQuestion.find_or_initialize_by(title: 'Will you stay at one of the suggested hotels?',
                                           question_type_id: qtype.id,
                                           global: true)
    # Save question
    q.save!

    # Associate answers with the question, unless they already exist
    qa_yes = TempQanswer.find_or_initialize_by(question_id: q.id, answer_id: answer_yes.id)
    qa_no = TempQanswer.find_or_initialize_by(question_id: q.id, answer_id: answer_no.id)

    # Save question-answer associations
    qa_yes.save!
    qa_no.save!

    TempConference.all.each do |c|
      # Make the question available for the conference
      TempConferencesQuestions.find_or_create_by!(conference_id: c.id, question_id: q.id)

      TempRegistration.where(conference_id: c.id).each do |r|
        if r.using_affiliated_lodging
          TempQanswerRegistration.find_or_create_by!(registration_id: r.id, qanswer_id: qa_yes.id)
        else
          TempQanswerRegistration.find_or_create_by!(registration_id: r.id, qanswer_id: qa_no.id)
        end
      end
    end
    remove_column :registrations, :using_affiliated_lodging, :boolean
  end
end
