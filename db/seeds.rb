# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Role.create(:name => "Participant")
Role.create(:name => "Organizer")
Role.create(:name => "Admin")

qtype_yesno = QuestionType.create(:title => "Yes/No")
qtype_single = QuestionType.create(:title => "Single Choice")
qtype_multiple = QuestionType.create(:title => "Multiple Choice")

answer_yes = Answer.create(:title => "Yes")
answer_no = Answer.create(:title => "No")

questions_yes_no = ["Do you need handicapped access?", "Will you attend with a partner?", "Will you attend the social event(s)?", "Will you stay at one of the suggested hotels?"]

for i in questions_yes_no do
  q = Question.create(:title => i, :question_type_id => qtype_yesno.id, :global => true)

  Qanswer.create(:question_id => q.id, :answer_id => answer_no.id)
  Qanswer.create(:question_id => q.id, :answer_id => answer_yes.id)
end
