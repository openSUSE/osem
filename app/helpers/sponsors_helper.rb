module SponsorsHelper
  # returns the url to be used for logo on basis of sponsorship level position
  def get_logo(sponsor)
    if sponsor.sponsorship_level.position == 1
      sponsor.picture.first.url
    elsif sponsor.sponsorship_level.position == 2
      sponsor.picture.second.url
    else
      sponsor.picture.others.url
    end
  end
end
