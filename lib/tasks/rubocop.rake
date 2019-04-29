# frozen_string_literal: true

require 'rubocop/rake_task'

namespace :rubocop do
  desc 'Generate .rubocop_todo.yml'
  task :auto_gen_config do
    sh 'rubocop --display-cop-names --auto-gen-config --auto-gen-only-exclude'
  end
end

desc 'Run RuboCop on the whole project'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = []
  task.options = ['--display-cop-names']
end
