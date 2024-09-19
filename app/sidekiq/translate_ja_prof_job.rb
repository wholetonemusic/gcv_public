class TranslateJaProfJob
  include Sidekiq::Job

  def perform(profile_id)
    profile = Profile.find(profile_id)
    profile.translate_ja_attributes
  end
end
