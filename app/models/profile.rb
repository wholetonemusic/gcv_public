# frozen_string_literal: true

# member profile
class Profile < ApplicationRecord
  include TranslateJa
  # ProfileJa module can be rendering in views with translate lang
  include ProfileJa
  translates

  belongs_to :member
  has_many :entries, through: :member

  has_one_attached :avatar_image, dependent: :destroy
  has_one_attached :background_image, dependent: :destroy

  has_many :notifications, dependent: :destroy

  has_one :translate_ja_profile, dependent: :destroy

  validates :avatar_image, :background_image,
            content_type: ['image/png', 'image/jpg', 'image/jpeg'],
            dimension: { width: { max: 4000 }, height: { max: 4000 } }

  validates :login,
            presence: true,
            uniqueness: true,
            length: { maximum: 50 }

  validates :about_me,
            length: { maximum: 10_000 }

  validates :play_field, :favorite_guitarist, :favorite_studybook,
            :favorite_band, :favorite_album, :favorite_video,
            :favorite_song, :play_history, :band, :blog, :website, :style,
            :youtube, :twitter,
            length: { maximum: 2000 }

  def translate_ja_login
    translogin = check_ja_string
    (translate_ja_profile || create_translate_ja_profile).update(login: translogin.titleize)
  end

  def translate_ja_attributes
    attr = set_attributes
    return unless login.contains_japanese? || attr.any? { |_key, value| value.contains_japanese? }

    translate_ja_login
    return unless attr.any? { |_key, value| value.contains_japanese? }

    trans_attr = Profile.google_trans(attr)
    (translate_ja_profile || create_translate_ja_profile).update(trans_attr)
  end

  def self.translate_ja_attributes_all
    all.each(&:translate_ja_attributes)
  end

  def translate_bg_job
    TranslateJaProfJob.perform_async(id)
  end

  private

  # must install https://github.com/loretoparisi/kakasi
  # and make install, before use kakasi gem
  def check_ja_string
    Kakasi.kakasi('-Ha -Ka -Ja -Ea -ka', login)
  rescue StandardError
    Profile.google_trans({login: login}).fetch(:login)
  end

  def set_attributes
    attributes.except('id', 'member_id', 'login', 'created_at', 'updated_at')
              .delete_if { |_key, value| value.nil? }
              .delete_if { |_key, value| value == '' }
  end
end
