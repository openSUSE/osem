# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create sample user
user = User.find_or_initialize_by(email: 'deleted@localhost.osem', name: 'User deleted',
                                  username: 'deleted_user', is_disabled: true,
                                  biography: 'Data is no longer available for deleted user.')
user.password = Devise.friendly_token[0, 20]
user.skip_confirmation!
user.save!

# Questions
qtype_yesno = QuestionType.find_or_create_by!(title: 'Yes/No')
QuestionType.find_or_create_by!(title: 'Single Choice')
QuestionType.find_or_create_by!(title: 'Multiple Choice')

answer_yes = Answer.find_or_create_by!(title: 'Yes')
answer_no = Answer.find_or_create_by!(title: 'No')

questions_yes_no = ['Do you need handicapped access?',
                    'Will you attend with a partner?',
                    'Will you attend the social event(s)?',
                    'Will you stay at one of the suggested hotels?']

questions_yes_no.each do |i|
  q = Question.find_or_initialize_by(title: i, question_type_id: qtype_yesno.id, global: true)
  q.answers = [answer_yes, answer_no]
  q.save!
end
