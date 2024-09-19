module CommentJa
  extend ActiveSupport::Concern
  included do

  # all attributes overwride below
  #
  # def login
  #   if locale_ja?
  #     super
  #   elsif translate_ja_profile.present?
  #     translate_ja_comment.body
  #   else
  #     super
  #   end
  # end

    def self.translates
      attrs = [:body]
      attrs.each do |attr|
        define_method(attr) do
          if locale_ja?
            super()
          elsif translate_ja_comment.present?
            translate_ja_comment.send(attr)
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
