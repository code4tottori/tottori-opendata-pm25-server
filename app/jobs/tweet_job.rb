class TweetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    return if ENV['TWITTER_NOTIFICATION'].blank?
    @threshold = ENV['NOTIFICATION_THRESHOLD'].to_i
    @threshold = 35 if @threshold.zero?
    results = {}
    data = Record.get_current_data
    data[:values].each do |name, value|
      if value > @threshold
        results[name] = value
      end
    end
    return if results.empty?
    message = ''
    message << '【鳥取県PM2.5情報】'
    message << data[:time].strftime('%m月%d日')
    message << "#{data[:time].hour + 1}時現在、"
    message << "次の測定局でPM2.5の濃度が#{@threshold} μg/m³を超えました。"
    message << results.to_a.map{ |e| e.join(' ') }.join(' ')
    message << ' http://tottori-taiki.users.tori-info.co.jp/taiki/pc/graph/'
    message << ' #tottoriken'
    message << ' #opendata'
    tweet(message)
  end

  def tweet(message)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
    client.update(message)
  end

end
