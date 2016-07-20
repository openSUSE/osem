class TwitterWrapper
  attr_accessor :client

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["OSEM_TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["OSEM_TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["OSEM_TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["OSEM_TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  ##
  #Fetches tweets from twitter api based on search_term and no_of_tweets
  #
  def search_tweets(no_of_tweets, search_term)
    begin
      @client.search(search_term, result_type: "recent").take(no_of_tweets).collect
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end

end
