class TranslateJaEntryJob
  include Sidekiq::Job

  def perform(entry_id)
    entry = Entry.find(entry_id)
    entry.translate_ja_attributes
  end
end
