class Member < ApplicationRecord
  has_one :profile, dependent: :destroy
  after_create do
    self.create_profile(login: "guest#{self.id}member")
  end

  has_many :entries, dependent: :destroy

  has_many :votes, dependent: :destroy

  has_many :notifications, dependent: :destroy, as: :recipient

  has_many :collection_votes, -> { where(vote_scope: Vote_collection) },
    class_name: "Vote"
  has_many :entry_collections, through: :collection_votes, source: :votable,
    source_type: "Entry"

  has_many :favorite_votes, -> { where(vote_scope: Vote_favorite) },
    class_name: "Vote"
  has_many :entry_favorites, through: :favorite_votes, source: :votable,
    source_type: "Entry"

  has_many :like_votes, -> { where(vote_scope: Vote_like) },
    class_name: "Vote"
  has_many :entry_likes, through: :like_votes, source: :votable,
    source_type: "Entry"

  has_many :follow_votes, -> { where(vote_scope: Vote_follow) },
    class_name: "Vote"
  has_many :follows, through: :follow_votes, source: :votable,
    source_type: "Member"

  has_many :follower_votes, -> { where(vote_scope: Vote_follow) },
    class_name: "Vote", as: :votable, dependent: :destroy
  has_many :followers, through: :follower_votes, source: :member

  has_many :block_votes, -> { where(vote_scope: Vote_block) },
    class_name: "Vote"

  has_many :blocker_votes, -> { where(vote_scope: Vote_block) },
    class_name: "Vote", as: :votable, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  #      :omniauthable, omniauth_providers: %i[twitter facebook google_oauth2]

  acts_as_commontator

  validate :positive_count

  # 'devise-enryptable' gem use resutful_authticate algorithm
  def valid_password?(password)
    if self.legacy_password.present? && self.legacy_salt.present?
      salt = self.legacy_salt
      re_legacy_password = Devise::Encryptable::Encryptors::RestfulAuthenticationSha1.
        digest(password, 1, salt, "")
      if re_legacy_password == self.legacy_password
        self.password = password
        self.legacy_password = nil
        self.legacy_salt = nil
        self.save!
        true
      else
        super
      end
    else
      super
    end
  end

  def reset_password(*args)
    self.encrypted_password = ""
    super
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |member|
      member.uid = auth.uid
      member.email = auth.info.email.present? ? auth.info.email : "#{auth.uid}@gcv.com"
      member.password = Devise.friendly_token[0, 20]
    end
  end

  def follow_by(member)
    if blocked?(member) || is_self?(member) || followed?(member)
      return true
    elsif !blocked?(member) && !is_self?(member) && !followed?(member)
      vote_find(member).first_or_create.update(vote_scope: Vote_follow)
      # call_back class vote update_counters_with_follow
    end
  end

  def unfollow_by(member)
    if followed?(member)
      vote_find(member).first_or_create.update(vote_scope: Vote_unfollow)
      # call_back class vote update_counters_with_unfollow
    elsif !followed?(member)
      return false
    end
  end

  def block_to(member)
    if blocked?(member)
      return true
    elsif !blocked?(member)
      block_find_to(member).first_or_create
      # call_back class vote update_counters_with_block
    end
  end

  def unblock_to(member)
    if blocked?(member)
      block_find_to(member).destroy_all
    elsif !blocked?(member)
      return false
    end
  end

  def followed?(member)
    follow_find_by(member).exists?
  end

  def blocked?(member)
    block_find_to(member).exists?
  end

  def is_self?(member)
    self == member
  end

  def followed_at_desc
    follows = self.follow_votes.select(:votable_id).map{ |v| v.votable_id }
    blockers = self.blocker_votes.select(:member_id).map{ |v| v.member_id }
    result_ids = follows - blockers 
    self.follow_votes.where(votable_id: result_ids).order('created_at desc')
  end

  def follower_at_desc 
    followers = self.follower_votes.select(:member_id).map{ |v| v.member_id }
    blocks = self.block_votes.select(:votable_id).map{ |v| v.votable_id }
    result_ids = followers - blocks
    self.follower_votes.where(member_id: result_ids).order('created_at desc')
  end

  private

  def positive_count
    if follow_count.negative?
      self.follow_count = 0
    elsif follower_count.negative?
      self.follower_count = 0
    end
  end

  def follow_find_by(member)
    follower_votes.where(member: member)
  end

  def block_find_to(member)
    follow_votes.except(:where).
      where(member: self, votable: member, vote_scope: Vote_block)
  end

  def vote_find(member)
    follower_votes.except(:where).where(member: member, votable: self)
  end
end
