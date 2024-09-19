# frozen_string_literal: true

# collection, follow, block .. votes
class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :member

  searchkick
  scope :search_import, -> { includes(:votable) }

  def search_data
    {
      member_id: member_id.to_s,
      vote_scope: vote_scope.to_s,
      votable_type: votable.class.to_s,
      votable_id: votable.id.to_s,
      votable_heading: votable.instance_of?(Entry) ? votable.heading.to_s : '',
      votable_maker: votable.instance_of?(Entry) ? votable.maker.to_s : '',
      votable_geartype: votable.instance_of?(Entry) ? votable.geartype.to_s : '',
      votable_guitarbody: votable.instance_of?(Entry) ? votable.guitarbody.to_s : '',
      votable_finish: votable.instance_of?(Entry) ? votable.finish.to_s : '',
      votable_neck: votable.instance_of?(Entry) ? votable.neck.to_s : '',
      votable_pickup: votable.instance_of?(Entry) ? votable.pickup.to_s : ''
    }
  end

  validates :member_id, :votable_type, :votable_id, :vote_scope, presence: true

  validates :votable_type, :vote_scope, length: { maximum: 50 }

  after_save if: proc { |vote| vote.vote_scope == 1 } do
    update_counters_with_collect
    create_notification_with_collect
  end

  # if entry uncollect or entry dependent destroy or member dependent destroy
  before_destroy :update_counters_with_uncollect,
                 prepend: true,
                 if: proc { |vote| vote.vote_scope == 1 }

  after_save if: proc { |vote| vote.vote_scope == 2 } do
    update_counters_with_follow
    create_notification_with_follow
  end

  # if member dependent destroy
  before_destroy :update_counters_with_unfollow,
                 prepend: true,
                 if: proc { |vote| vote.vote_scope == 2 }

  after_save :update_counters_with_unfollow,
             if: proc { |vote| vote.vote_scope == 3 }

  after_save :update_counters_with_block,
             if: proc { |vote| vote.vote_scope == 4 }

  after_save :create_notification_with_favorite,
             if: proc { |vote| vote.vote_scope == 5 }

  after_save :create_notification_with_like,
             if: proc { |vote| vote.vote_scope == 6 }

  def update_counters_with_collect
    Entry.update_counters(votable.id, collector_count: 1)
  end

  def update_counters_with_uncollect
    Entry.update_counters(votable.id, collector_count: -1)
  end

  def update_counters_with_follow
    Member.update_counters(member.id, follow_count: 1)
    Member.update_counters(votable.id, follower_count: 1)
  end

  def update_counters_with_unfollow
    Member.update_counters(member.id, follow_count: -1) if counter_positive(member.follow_count)
    Member.update_counters(votable.id, follower_count: -1) if counter_positive(votable.follower_count)
  end

  def update_counters_with_block
    Member.update_counters(member.id, follower_count: -1) if counter_positive(member.follower_count)
    Member.update_counters(votable.id, follow_count: -1) if counter_positive(votable.follow_count)
    Vote.where(
      member_id: votable.id,
      votable_id: member.entry_ids,
      vote_scope: 1
    ).destroy_all
    Vote.where(
      member_id: votable.id,
      votable_id: member.entry_ids,
      vote_scope: 5
    ).destroy_all
    Vote.where(
      member_id: votable.id,
      votable_id: member.entry_ids,
      vote_scope: 6
    ).destroy_all
  end

  def create_notification_with_collect
    VoteNotification.with(
      heading: "collected #{votable.heading}",
      profile_id: member.profile.id
    ).deliver(votable.member)
  end

  def create_notification_with_follow
    VoteNotification.with(
      heading: "followed #{votable.profile.login}",
      profile_id: member.profile.id
    ).deliver(votable)
  end

  def create_notification_with_favorite
    VoteNotification.with(
      heading: "added favorite #{votable.heading}",
      profile_id: member.profile.id
    ).deliver(votable.member)
  end

  def create_notification_with_like
    VoteNotification.with(
      heading: "liked #{votable.heading}",
      profile_id: member.profile.id
    ).deliver(votable.member)
  end

  private

  def counter_positive(counter)
    true if counter.positive? && !counter.zero?
  end
end
