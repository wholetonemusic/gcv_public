class ManagesController < ApplicationController
  before_action :authenticate_member!

  def my_entries
    @entries = current_member.entries.
        order('created_at desc').page(params[:page]).per_page(12)
    @search = params[:search]
    if @search.present?
      @search = params.require(:search).permit(:q)
      @q = @search["q"]
      # searchkick
      @entries = Entry.search(@q,
        where: { member_id: current_member.id },
        page: params[:page], per_page: 12)
    else
      @entries
    end
  end

  def entry_collections
    @collections = current_member.collection_votes.
        order('created_at desc').includes(:votable).page(params[:page]).per_page(12)
    @search = params[:search]
    if @search.present?
      @search = params.require(:search).permit(:q)
      @q = @search["q"]
      # searchkick
      @collections = Vote.search(@q,
        where: { member_id: current_member.id, vote_scope: 1 },
        page: params[:page], per_page: 12)
    else
      @collections
    end
  end

  def entry_favorites
    @favorites = current_member.favorite_votes.
        order('created_at desc').includes(:votable).page(params[:page]).per_page(12)
    @search = params[:search]
    if @search.present?
      @search = params.require(:search).permit(:q)
      @q = @search["q"]
      # searchkick
      @favorites = Vote.search(@q,
        where: { member_id: current_member.id, vote_scope: 5 },
        page: params[:page], per_page: 12)
    else
      @favorites
    end
  end

  def member_follows
    @follows = current_member.followed_at_desc.page(params[:page]).per_page(12)
  end

  def member_followers
    @followers = current_member.follower_at_desc.page(params[:page]).per_page(12)
  end

end
