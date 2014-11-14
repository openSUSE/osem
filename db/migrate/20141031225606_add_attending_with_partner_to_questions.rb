class AddAttendingWithPartnerToQuestions < ActiveRecord::Migration
  class TempRegistration < ActiveRecord::Base
    self.table_name = 'registrations'

    belongs_to :temp_conference
    attr_accessible :attending_with_partner
  end

  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'

    has_many :temp_registrations
    has_many :temp_questions
  end

  class TempQuestionType < ActiveRecord::Base
    self.table_name = 'question_types'

    attr_accessible :title
    has_many :temp_questions
  end

  class TempQuestion < ActiveRecord::Base
    self.table_name = 'questions'

    attr_accessible :title, :global, :question_type_id
    has_many :temp_qanswers
    has_many :temp_answers, through: :temp_qanswers
    belongs_to :temp_question_type
    has_and_belongs_to_many :temp_conferences
  end

  class TempAnswer < ActiveRecord::Base
    self.table_name = 'answers'

    attr_accessible :title
    has_many :temp_qanswers
    has_many :temp_questions, through: :temp_qanswers
  end

  class TempQanswer < ActiveRecord::Base
    self.table_name = 'qanswers'

    attr_accessible :question_id, :answer_id
    belongs_to :temp_question
    belongs_to :temp_answer
  end

  class TempConferencesQuestions < ActiveRecord::Base
    self.table_name = 'conferences_questions'

    attr_accessible :question_id, :conference_id
  end

  class TempQanswerRegistration < ActiveRecord::Base
    self.table_name = 'qanswers_registrations'

    attr_accessible :registration_id, :qanswer_id
  end

  def change
    # Create Question of yes/no type
    qtype = TempQuestionType.find_or_create_by!(title: 'Yes/No')
    answer_yes = TempAnswer.find_or_create_by!(title: 'Yes')
    answer_no = TempAnswer.find_or_create_by!(title: 'No')

    # Find existing question or initialize it
    q = TempQuestion.find_or_initialize_by(title: 'Will you attend with a partner?',
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
	if r.attending_with_partner
	  TempQanswerRegistration.find_or_create_by!(registration_id: r.id, qanswer_id: qa_yes.id)
	else
	  TempQanswerRegistration.find_or_create_by!(registration_id: r.id, qanswer_id: qa_no.id)
	end
      end
    end
    remove_column :registrations, :attending_with_partner, :boolean
  end
end
