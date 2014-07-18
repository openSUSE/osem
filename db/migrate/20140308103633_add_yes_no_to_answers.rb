class AddYesNoToAnswers < ActiveRecord::Migration
  def change
    answer_yes = Answer.where(:title => "Yes").first
    Answer.create(:title => "Yes") if answer_yes == nil    

    answer_no = Answer.where(:title => "No").first
    Answer.create(:title => "No") if answer_no == nil    
  end
end
