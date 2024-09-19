# frozen_string_literal: true

# twitter bot
class Social < ApplicationRecord
  def self.will_unfollow_save_differ
    diff_ids = pull_my_following_ids - pull_my_follower_ids
    diff_ids.each do |u_id|
      create(user_id: u_id.to_i, provider: 'twitter', status: 'notfollower')
    end
  end

  # if following user do not followback past 5days, willunfollow set
  def self.will_unfollow_set_pass5days
    notfollower = where(status: 'following', created_at: 30.days.ago..5.days.ago).first
    return unless notfollower.present?

    if twitter_access.user(notfollower.user_id).attrs[:following] == true
      notfollower.update(status: 'ck_following') # check following
      logger.info("check is done. #{notfolloer.user_id} is follower")
      nil
    else
      logger.info("check is done. #{notfolloer.user_id} is notfollower")
      notfollower.user_id
    end
  rescue StandardError
    notfollower.update(status: 'neverfollow')
  end

  def self.will_unfollow_set_old
    notfollower = where(status: 'notfollower').first
    return unless notfollower.present?

    notfollower.user_id
  end

  def self.unfollow_notfollower(id)
    notfollower = where(user_id: id).first
    return unless notfollower.present?

    notfollower.update(status: 'neverfollow')
    twitter_access.unfollow(notfollower.user_id)
  rescue StandardError
    notfollower.update(status: 'neverfollow')
  end

  def self.will_follows_save(user_id)
    search_will_follows(user_id)
  end

  def self.follow_willfollow
    willfollow = where(status: 'willfollow').first
    return unless willfollow.present?

    willfollow.update(status: 'following')
    twitter_access.follow(willfollow.user_id)
  rescue StandardError
    willfollow.update(status: 'neverfollow')
  end

  # searching my follower's following who guitarist #15129744(my id), return array of ids
  # api get friends/list, rate limit is 15req/15min
  def self.search_will_follows(user_id)
    ids = en_follower_ids(user_id)
    ids.each do |id|
      twitter_access.friends(id).attrs[:users].each do |user|
        next unless user[:status] &&
                    user[:status][:lang] == 'en' &&
                    user[:description].match?(/guitar|Guitar|GUITAR/) &&
                    user[:following] == false &&
                    user[:id] != '15129744'.to_i
        next if where(user_id: user[:id]).present?

        create(user_id: user[:id], provider: 'twitter', status: 'willfollow')
        logger.info("userid[#{id}]")
        logger.info("#{Time.now} create willfollow id[#{user[:id]}] at Social.search_will_follows")
        logger.info(user[:description])
      end
      logger.info('sleeping 66')
      sleep 66
    end
  end

  # user(id) follower whos lang en, return array of ids
  # api get followers/list, rate limit is 15req/15min
  def self.en_follower_ids(user_id)
    en_follower_ids = []
    twitter_access.followers(user_id).attrs[:users].each do |user|
      next unless user[:status] && user[:status][:lang] == 'en'

      en_follower_ids.push(user[:id])
    end
    en_follower_ids.flatten
  end

  def self.pull_my_follower_ids
    followers_array = []
    fcursor = -1
    while fcursor != 0
      response = twitter_access.follower_ids({ cursor: fcursor })
      followers = response.attrs[:ids]
      followers_array.push(followers)
      fcursor = response.attrs[:next_cursor]
    end
    followers_array.flatten
  end

  def self.pull_my_following_ids
    followings_array = []
    fcursor = -1
    while fcursor != 0
      response = twitter_access.friend_ids({ cursor: fcursor })
      followings = response.attrs[:ids]
      followings_array.push(followings)
      fcursor = response.attrs[:next_cursor]
    end
    followings_array.flatten
  end

  def self.twitter_access
    Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.twitter[:api_key]
      config.consumer_secret     = Rails.application.credentials.twitter[:api_key_secret]
      config.access_token        = Rails.application.credentials.twitter[:access_token]
      config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
    end
  end

  def logger
    Logger.new(Rails.root.join('log/twitter_bot.log'))
  end
end
