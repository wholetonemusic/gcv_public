class VotesController < ApplicationController
  before_action :set_member, only: [:follow, :unfollow, :block, :unblock]
  before_action :set_entry, only: [:entry_collection, :entry_uncollection,
                :entry_favorite, :entry_unfavorite, :entry_like, :entry_unlike]
  load_and_authorize_resource

  def follow
    @member.follow_by(current_member)
    respond_to do |format|
      format.html { redirect_to profile_path(@member.profile) }
    end
  end

  def unfollow
    @member.unfollow_by(current_member)
    respond_to do |format|
      if params[:manage] == 'member'
        format.html { redirect_to manages_member_follows_path }
      else
        format.html { redirect_to profile_path(@member.profile) }
      end
    end
  end

  def block
    current_member.block_to(@member)
    respond_to do |format|
      if params[:manage] == 'member'
        format.html { redirect_to manages_member_followers_path }
      else
        format.html { redirect_to profile_path(@member.profile) }
      end
    end
  end

  def unblock
    current_member.unblock_to(@member)
    respond_to do |format|
      format.html { redirect_to profile_path(@member.profile) }
    end
  end

  def entry_collection
    @entry.collect_by(current_member)
    respond_to do |format|
      format.html { redirect_to entry_path(@entry) }
    end
  end

  def entry_uncollection
    @entry.uncollect_by(current_member)
    respond_to do |format|
      if params[:manage] == 'member'
        format.html { redirect_to manages_entry_collections_path }
      else
        format.html { redirect_to entry_path(@entry) }
      end
    end
  end

  def entry_favorite
    @entry.favorite_by(current_member)
    respond_to do |format|
      format.html { redirect_to entry_path(@entry) }
    end
  end

  def entry_unfavorite
    @entry.unfavorite_by(current_member)
    respond_to do |format|
      if params[:manage] == 'member'
        format.html { redirect_to manages_entry_favorites_path }
      else
        format.html { redirect_to entry_path(@entry) }
      end
   end
  end

  def entry_like
    @entry.like_by(current_member)
    respond_to do |format|
      format.html { redirect_to entry_path(@entry) }
    end
  end

  def entry_unlike
    @entry.unlike_by(current_member)
    respond_to do |format|
      format.html { redirect_to entry_path(@entry) }
    end
  end

  private

  def set_member
    @member = Member.find(params.require(:follow_id))
  end

  def set_entry
    @entry = Entry.find(params.require(:entry_id))
  end
end
