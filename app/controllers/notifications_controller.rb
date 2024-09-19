# frozen_string_literal: true

# notifications for a current_member
class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[update]
  # cancan authentication
  load_and_authorize_resource

  def index
    @notifications = current_member.notifications.limit(100).includes(:sender).page(params[:page]).per_page(12)
  end

  def update
    respond_to do |format|
      if @notification.mark_as_read!
        format.html { redirect_to profile_path(@notification.sender) }
      else
        format.html { redirect_to member_root_path }
      end
    end
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  # def notification_params
  #   params.require(:notification).permit(
  #     :recipient_type,
  #     :recipient_id,
  #     :type,
  #     :params,
  #    :read_at,
  #    :profile_id
  #   )
  # end
end
