module EntryJa
  extend ActiveSupport::Concern
  included do

  # all attributes overwride below
  #
  # def heading
  #   if locale_ja?
  #     super
  #   elsif translate_ja_entry.present?
  #     translate_ja_entry.heading
  #   else
  #     super
  #   end
  # end

    def self.translates
      attrs = [
        :heading,
        :maker,
        :model,
        :year,
        :serial,
        :madein,
        :sound,
        :price,
        :category,
        :geartype,
        :guitarbody,
        :neck,
        :fboard,
        :peg,
        :fret,
        :scale,
        :pickup,
        :controlls,
        :bridge,
        :finish,
        :body,
        :weight
      ]
      attrs.each do |attr|
        define_method(attr) do
          if locale_ja? && translate_ja_entry.present?
            translate_ja_entry.send(attr)
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
