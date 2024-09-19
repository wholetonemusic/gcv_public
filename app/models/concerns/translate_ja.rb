# frozen_string_literal: true

require 'active_support/concern'
require 'google/cloud/translate/v3'

# translate JA to EN
module TranslateJa
  extend ActiveSupport::Concern
  class_methods do
    def google_client
      Google::Cloud::Translate::V3::TranslationService::Client.new do |config|
        config.credentials = Rails.root.join('config', 'google_cloud.json').to_s
      end
    end

    def google_trans_request(contents)
      Google::Cloud::Translate::V3::TranslateTextRequest.new(
        contents: contents,
        parent: 'projects/guitar-cv',
        target_language_code: 'en'
      )
    end

    def google_trans(attr)
      client = google_client
      contents = attr.map { |_key, value| value }
      request = google_trans_request(contents)
      result = client.translate_text(request)
                     .translations.map(&:translated_text)
      attr.map { |key, _value| key }.zip(result).to_h
    end

    def deepl_client
      DeepL.configure do |config|
        config.auth_key = Rails.application.credentials.deepl[:secret_key]
        config.host = 'https://api.deepl.com'
        config.version = 'v2'
      end
    end

    def deepl_trans(attr)
      deepl_client
      contents = attr.map { |_key, value| value }
      result = DeepL.translate(contents, nil, 'EN')
      if result.kind_of?(DeepL::Resources::Text)
        re_result = result.text.split
      elsif result.kind_of?(Array)
        re_result = result.map(&:text)
      end
      attr.map { |key, _value| key }.zip(re_result).to_h
    end

    def hankaku_trans(attr)
      contents = attr.map { |_key, value| value }
      contents.each do |val|
        # change zenkaku to hankaku characters except katakana.
        val.replace(Moji::han_to_zen(val.zen_to_han, Moji::HAN_KATA))
      end
      attr.map { |key, _value| key }.zip(contents).to_h
    end
  end
end
