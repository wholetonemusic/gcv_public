class TranslateJaCommentJob
  include Sidekiq::Job

  def perform(comment_id)
    comment = Commontator::Comment.find(comment_id)
    comment.translate_ja_attributes
  end
end
