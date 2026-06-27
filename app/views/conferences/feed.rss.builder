xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "#{ENV.fetch('OSEM_NAME', 'OSEM')} - Conferences"
    xml.description "Conferences from #{ENV.fetch('OSEM_NAME', 'OSEM')}"
    xml.link conferences_url

    @conferences.each do |conference|
      xml.item do
        xml.title conference.title
        xml.description conference.description
        xml.pubDate conference.created_at.to_fs(:rfc822)
        xml.link conference_url(conference.short_title)
        xml.guid conference_url(conference.short_title)
      end
    end
  end
end
