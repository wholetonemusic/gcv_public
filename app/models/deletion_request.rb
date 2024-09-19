# frozen_string_literal: true

# delete user data request from facebook
class DeletionRequest < ApplicationRecord
  after_save :delete_member
  
  validates_presence_of :uid, :provider, :pid

  # there can only be one entry with given provider + uid
  validates_uniqueness_of :uid, scope: :provider

  before_validation :set_pid

  def deleted?
    Member.where(provider: provider, uid: uid).count.zero?
  end

  def self.parse_fb_request(req)
    encoded, payload = req.split('.', 2)
    decoded = Base64.urlsafe_decode64(encoded)
    data = JSON.parse(Base64.urlsafe_decode64(payload))
    # we need to verify the digest is the same
    exp = OpenSSL::HMAC.digest(
      'SHA256',
      Rails.application.credentials.facebook[:app_secret],
      payload
    )
    unless decoded == exp
      puts 'FB deletion callback called with weird data'
      return nil
    end
    data
  end

  private

  def set_pid
    self.pid = random_pid if pid.blank?
  end

  def random_pid
    SecureRandom.hex(4)
  end

  def delete_member
    member = Member.where(provider: provider, uid: uid).last
    member.destroy
  end
end
