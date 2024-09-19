class MembersController < ApplicationController
  # divese authentication
  before_action :authenticate_member!

  def home
    @notifications = current_member.notifications.unread.includes(:sender).limit(5)
    @entries = current_member.entries.order('created_at desc').limit(5)
    @collections = current_member.collection_votes.order('created_at desc').includes(:votable).limit(5)
    @follows = member_follows
    @followers = member_followers
  end

  private
  
  def member_follows
    follows = current_member.follow_votes.select(:votable_id).map{ |v| v.votable_id }
    blockers = current_member.blocker_votes.select(:member_id).map{ |v| v.member_id }
    result_ids = follows - blockers 
    current_member.follow_votes.where(votable_id: result_ids).order('created_at desc').limit(5)
  end

  def member_followers
    followers = current_member.follower_votes.select(:member_id).map{ |v| v.member_id }
    blocks = current_member.block_votes.select(:votable_id).map{ |v| v.votable_id }
    result_ids = followers - blocks
    current_member.follower_votes.where(member_id: result_ids).order('created_at desc').limit(5)
  end

end
