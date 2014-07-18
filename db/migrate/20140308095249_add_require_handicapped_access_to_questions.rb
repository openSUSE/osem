require "./db/migrate/20140308100155_add_data_to_question_types.rb"
require "./db/migrate/20140308103633_add_yes_no_to_answers.rb"

class AddRequireHandicappedAccessToQuestions < ActiveRecord::Migration
  def change
    AddDataToQuestionTypes.new.migrate(:up)
    AddYesNoToAnswers.new.migrate(:up)

    qtitle = "Do you need handicapped access?"
    # Find Answer 'Yes'
    answer_yes = Answer.where(:title => "Yes").first
    # Check if Question already exists    
    q = Question.where(:title => qtitle).first
    # If question does not exist
    if q == nil
      # Get Question Type and Answer 'No' 
      qtype = QuestionType.where(:title => "Yes/No").first
      answer_no = Answer.where(:title => "No").first
      # Create Question
      q = Question.create(:title => qtitle, :question_type_id => qtype.id, :global => true, :answer_ids => [answer_yes.id, answer_no.id])
    end

    # Find Qanswer with answer 'Yes' and associate it with registrations
    qa_yes = Qanswer.where(:question_id => q.id).where(:answer_id => answer_yes.id).first

    Conference.all.each do |c|
      if c.registrations.where(:handicapped_access_required => true).count > 0
        c.question_ids = c.question_ids << q.id
        c.registrations.where(:handicapped_access_required => true).each do |r|
          r.qanswer_ids = r.qanswer_ids << qa_yes.id
        end
      end
    end    

  end
end
