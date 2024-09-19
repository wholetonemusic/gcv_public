# frozen_string_literal: true

# twite entry and follow
module TwitterBot
  extend ActiveSupport::Concern
  included do

    def twite_entry
      update_twite_entry
    end

    def twite_new_entry
      update_twite_new_entry
    end

    private

    def twitter_access
      Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:api_key]
        config.consumer_secret     = Rails.application.credentials.twitter[:api_key_secret]
        config.access_token        = Rails.application.credentials.twitter[:access_token]
        config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
      end
    end

    def update_twite_entry
      if !body.blank?
        update_entry_body
      elsif !sound.blank?
        update_entry_sound
      else
        update_default
      end
    end

    def update_twite_new_entry
      twitter_access.update(
        "RECENT POSTS - #{heading} https://guitar-cv.com/entries/#{id}"
      )
    end

    def update_entry_body
      twitter_access.update(
        "#{body.delete("\r\n").truncate(150).to_s} https://guitar-cv.com/entries/#{id}"
      )
    end

    def update_entry_sound
      twitter_access.update(
        "#{sound.delete("\r\n").truncate(150).to_s} https://guitar-cv.com/entries/#{id}"
      )
    end

    def update_default
      twitter_access.update(
        "GCV is a project site that archives guitars from around the world. https://guitar-cv.com/entries/#{id}"
      )
    end

  end
end
