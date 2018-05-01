# frozen_string_literal: true

namespace :data do
  namespace :migrate do
    desc 'Resize existing logo of sponsors after change in image manipulation specifications'
    task logo_reprocess: :environment do
      Sponsor.find_each { |s| s.picture.recreate_versions! if s.picture? }
    end
  end
end
