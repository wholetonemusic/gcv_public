module ProfileJa
  extend ActiveSupport::Concern
  included do

  # all attributes overwride below
  #
  # def login
  #   if locale_ja?
  #     super
  #   elsif translate_ja_profile.present?
  #     translate_ja_profile.login
  #   else
  #     super
  #   end
  # end

    def self.translates
      attrs = [
        :login,
        :about_me,
        :play_field,
        :favorite_guitarist,
        :favorite_studybook,
        :favorite_band,
        :favorite_album,
        :favorite_video,
        :favorite_song,
        :play_history,
        :band,
        :blog,
        :website,
        :youtube,
        :twitter,
        :style
      ]
      attrs.each do |attr|
        define_method(attr) do
          if locale_ja?
            super()
          elsif translate_ja_profile.present?
            translate_ja_profile.send(attr)
          else
            super()
          end
        end
      end
    end

    def locale_ja?
      return true if I18n.locale == :ja
    end
  end
end
