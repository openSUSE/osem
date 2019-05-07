# frozen_string_literal: true

unless Rails.env.production?
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = []
    task.options = ['--display-cop-names']
  end

  namespace :rubocop do
    desc 'Generate .rubocop_todo.yml'
    task :auto_gen_config do
      sh 'rubocop --display-cop-names --auto-gen-config --auto-gen-only-exclude'
    end
  end
end
