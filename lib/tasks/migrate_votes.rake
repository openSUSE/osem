namespace :votes do
  desc 'Migrate old votes to new voting system'
  task migrate: :environment do
    ActiveRecord::Base.transaction do
      Conference.all.each do |conf|
        VotableField.create(title: 'Overall', conference_id: conf.id, for_admin: true, stars: conf.program.rating, votable_type: 'Event')
        Event.all.each do |event|
          votes = Vote.where(event_id: event.id)
          break if votes.blank?
          avg_votes = votes.pluck(:rating).sum / votes.count
          votes.each do |vote|
            Rate.create(dimension: 'Overall', rater_id: vote.user_id, rateable_type: 'Event', stars: vote.rating, rateable_id: event.id)
          end
          RatingCache.create(cacheable_id: event.id, cacheable_type: 'Event', avg: avg_votes, qty: votes.count, dimension: 'Overall')
        end
      end
    end
    puts 'All done!'
  end
end
