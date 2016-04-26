namespace :logo do
  desc 'Resize existing logo of sponsors after change in image manipulation specifications'
  task reprocess: :environment do
    Sponsor.find_each { |s| s.logo.reprocess! }
  end
end
