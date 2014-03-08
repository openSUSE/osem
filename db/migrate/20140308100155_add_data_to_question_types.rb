class AddDataToQuestionTypes < ActiveRecord::Migration
  def change
    #Create Question Types (yes/no, single choice, multiple choice) if they don't already exist
    qtype_yesno = QuestionType.where(:title => "Yes/No").first
    QuestionType.create(:title => "Yes/No") if qtype_yesno == nil
    
    qtype_single = QuestionType.where(:title => "Single Choice").first
    QuestionType.create(:title => "Single Choice") if qtype_single == nil
    
    qtype_multiple = QuestionType.where(:title => "Multiple Choice").first
    QuestionType.create(:title => "Multiple Choice") if qtype_multiple == nil
  end
end
