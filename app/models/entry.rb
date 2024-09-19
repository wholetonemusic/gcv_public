# frozen_string_literal: true

# mnage gear entries
class Entry < ApplicationRecord
  include TranslateJa
  include EntryJa
  translates

  include TwitterBot

  belongs_to :member
  has_one :profile, through: :member

  has_many :collector_votes, -> { where(vote_scope: Vote_collection) },
           class_name: 'Vote', as: :votable, dependent: :destroy
  has_many :collectors, through: :collector_votes, source: :member

  has_many :favor_votes, -> { where(vote_scope: Vote_favorite) },
           class_name: 'Vote', as: :votable, dependent: :destroy
  has_many :favors, through: :favor_votes, source: :member

  has_many :like_votes, -> { where(vote_scope: Vote_like) },
           class_name: 'Vote', as: :votable, dependent: :destroy
  has_many :likers, through: :like_votes, source: :member

  has_many_attached :entry_images, dependent: :destroy do |attachable|
    attachable.variant :thumb, resize_to_limit: [700, 700]
  end

  has_one :translate_ja_entry, dependent: :destroy

  acts_as_commontable dependent: :destroy

  searchkick

  validates :entry_images,
            attached: true,
            presence: true,
            content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'],
            dimension: { width: { max: 4100 }, height: { max: 4100 } },
            limit: { min: 1, max: 4 }

  validates :body, length: { maximum: 10_000 }

  validates :sound, length: { maximum: 1_000 }

  validates :heading, :maker, :model, :year, :serial, :madein,
            :price, :geartype, :category, :weight,
            length: { maximum: 250 }

  validates :heading, :category, presence: true

  validates :vote_weight, inclusion: { in: [0, 1, 2, 3, 4, 5] }

  validates :category, inclusion: {
    in: %w[
      Electric-Solid-Body-Guitar
      Electric-Semi-Hollow-Body-Guitar
      Electric-Hollow-Body-Guitar
      Acoustic-Electric-Guitar
      Dreadnought-Acoustic-Guitar
      Classical-Acoustic-Guitar
      Pedal
      Amplifier
      Parts-Accessories
      Rec-Gear
      Others
    ]
  }

  def owner
    member.profile
  end

  def collect_by(member)
    collector_votes.create(member: member, votable: self, vote_scope: Vote_collection) unless cannot_collected?(member)
  end

  def uncollect_by(member)
    collect_find_by(member).destroy_all if collected?(member)
  end

  def collected?(member)
    collect_find_by(member).exists?
  end

  def cannot_collected?(member)
    blocked?(member) || collected?(member)
  end

  def favorite_by(member)
    favor_votes.create(member: member, votable: self, vote_scope: Vote_favorite) unless cannot_favorite?(member)
  end

  def unfavorite_by(member)
    favor_find_by(member).destroy_all if favorite?(member)
  end

  def favorite?(member)
    favor_find_by(member).exists?
  end

  def cannot_favorite?(member)
    blocked?(member) || favorite?(member)
  end

  def like_by(member)
    like_votes.create(member: member, votable: self, vote_scope: Vote_like) unless cannot_liked?(member)
  end

  def unlike_by(member)
    liker_find_by(member).destroy_all if liked?(member)
  end

  def liked?(member)
    liker_find_by(member).exists?
  end

  def blocked?(member)
    owner_block_find_to(member).exists?
  end

  def cannot_liked?(member)
    blocked?(member) || liked?(member)
  end

  def self.top_rand_entries(category, limit)
    Entry.joins(:entry_images_attachments).joins(:entry_images_blobs)
         .where(category: category).order(Arel.sql('RAND()'))
         .limit(limit).includes(:profile)
  end

  def similar_entries
    query = similar(
      includes: %i[entry_images_attachments entry_images_blobs],
      fields: %i[maker heading geartype guitarbody finish neck pickup]
    )
    query.results.sample(7)
  end

  def self.random_search(keyword)
    query = search(
      keyword, includes: %i[entry_images_attachments entry_images_blobs]
    )
    query.results.sample(7)
  end

  def self.aggs_category
    search('*', aggs: [:category]).aggs['category']['buckets']
  end

  def translate_ja_attributes
    attr = set_attributes
    return unless attr.any? { |_key, value| value.contains_japanese? }

    (translate_ja_entry || create_translate_ja_entry).update(attr)
    trans_attr = Entry.deepl_trans(attr)
    update(trans_attr)
    check_translated(trans_attr)
  end

  def translate_ja_attributes_all
    all.each(&:translate_ja_attributes)
  end

  def self.translate_ja_attributes_limit(limit, offset)
    entries = limit(limit).offset(offset)
    entries.each(&:translate_ja_attributes)
  end

  def zenkaku_to_hankaku
    attr = set_attributes
    trans_attr = Entry.hankaku_trans(attr)
    update(trans_attr)
    check_translated(trans_attr)
  end

  def self.zenkaku_to_hankaku_all
    ja_entry = TranslateJaEntry.where(translated: false)
    ja_entry.each { |je| je.entry.zenkaku_to_hankaku }
  end

  def check_translated(attr)
    return unless translate_ja_entry.present?

    if attr.any? { |_key, value| value.contains_japanese? }
      translate_ja_entry.update(translated: false)
    else
      translate_ja_entry.update(translated: true)
    end
  end

  def self.check_translated_all
    all.each { |e| e.check_translated(e.set_attributes) }
  end

  def translate_bg_job
    TranslateJaEntryJob.perform_async(id)
  end

  def set_attributes
    attributes.except(
      'id',
      'member_id',
      'vote_weight',
      'view_count',
      'collector_count',
      'created_at',
      'updated_at'
    ).delete_if { |_key, value| value.nil? }
     .delete_if { |_key, value| value == '' }
  end

  protected

  def collect_find_by(member)
    collector_votes.where(member: member)
  end

  def favor_find_by(member)
    favor_votes.where(member: member)
  end

  def liker_find_by(member)
    like_votes.where(member: member)
  end

  def owner_block_find_to(member)
    self.member.follow_votes.except(:where)
        .where(member: self.member, votable: member, vote_scope: Vote_block)
  end
end
