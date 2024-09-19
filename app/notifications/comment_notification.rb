# frozen_string_literal: true

# To deliver this notification:
#
# CommentNotification.with(comment: @comment).deliver_later(current_user)
# CommentNotification.with(comment: @comment).deliver(current_user)
class CommentNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database, format: :with_profile
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  params :heading, :profile_id

  def with_profile
    {
      type: self.class.name,
      params: params,
      profile_id: params[:profile_id]
    }
  end

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end
end
