module SponsorsHelper
  # returns the url to be used for logo on basis of sponsorship level position
  def get_logo(sponsor)
    if sponsor.sponsorship_level.position == 1
      sponsor.logo.url(:first)
    elsif sponsor.sponsorship_level.position == 2
      sponsor.logo.url(:second)
    else
      sponsor.logo.url(:others)
    end
  end
end
