require "rails_helper"

RSpec.describe Entry, type: :model do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :skip_validate,
                      member_id: member2.id, heading: "entry title")
  }

  describe 'vareilable votes to entry' do
    it "has many collectors" do
      entry.collector_votes.
        create(member: member, votable: entry, vote_scope: 1)
      expect(entry.collectors.first).to eq member
    end
  
    it "has many favors" do
      entry.favor_votes.
        create(member: member, votable: entry, vote_scope: 5)
      expect(entry.favors.first).to eq member
    end
  
    it "has many liker" do
      entry.like_votes.
        create(member: member, votable: entry, vote_scope: 6)
      expect(entry.likers.first).to eq member
    end
  
    it "has method that collect by member" do
      entry.collect_by(member)
      expect(entry.collectors.first).to eq member
    end
  
    it "has method that favorite by member" do
      entry.favorite_by(member)
      expect(entry.favors.first).to eq member
    end
  
    it "has method that like by member" do
      entry.like_by(member)
      expect(entry.likers.first).to eq member
    end
  
    it "after deleted have no votes associations" do
      entry.collect_by(member)
      entry.destroy
      expect(entry.collectors.count).to eq 0
    end
  
    it "collect by whose vote?" do
      entry.collect_by(member)
      expect(entry.collected?(member)).to eq true
      expect(entry.collected?(member2)).to eq false
    end
  
    it "has collector counter cache" do
      entry.collect_by(member)
      expect(Entry.find(entry.id).collector_count).to eq 1
    end
  
    it "invalid duplicate collection by same member" do
      2.times { entry.collect_by(member) }
      expect(member.entry_collections.count).to eq 1
      expect(Entry.find(entry.id).collector_count).to eq 1
    end
  
    it "invalid duplicate favorite by same member" do
      2.times { entry.favorite_by(member) }
      expect(member.entry_favorites.count).to eq 1
    end
  
    it "invalid duplicate like by same member" do
      2.times { entry.like_by(member) }
      expect(member.entry_likes.count).to eq 1
    end
  
    it "unvote members collection" do
      entry.collect_by(member)
      entry.uncollect_by(member)
      expect(member.entry_collections.count).to eq 0
      expect(Entry.find(entry.id).collector_count).to eq 0
    end
  
    it "unvote members favorites" do
      entry.favorite_by(member)
      entry.unfavorite_by(member)
      expect(member.entry_favorites.count).to eq 0
    end
  
    it "unvote members likes" do
      entry.like_by(member)
      entry.unlike_by(member)
      expect(member.entry_likes.count).to eq 0
    end
  
    it "block collection" do
      entry.collect_by(member)
      entry.member.block_to(member)
      expect(member.entry_collections.count).to eq 0
      expect(Entry.find(entry.id).collector_count).to eq 0
    end
  
    it "block favorite" do
      entry.favorite_by(member)
      entry.member.block_to(member)
      expect(member.entry_favorites.count).to eq 0
      expect(Entry.find(entry.id).favors.count).to eq 0
    end
  
    it "block like" do
      entry.like_by(member)
      entry.member.block_to(member)
      expect(member.entry_likes.count).to eq 0
      expect(Entry.find(entry.id).likers.count).to eq 0
    end
  
    it "blocked collector do not collect" do
      entry.collect_by(member)
      expect(member.entry_collections.count).to eq 1
      entry.member.block_to(member)
      expect(member.entry_collections.count).to eq 0
      2.times { entry.collect_by(member) }
      expect(Entry.find(entry.id).collector_count).to eq 0
    end
  
    it "blocked favor do not favorite" do
      entry.favorite_by(member)
      expect(member.entry_favorites.count).to eq 1
      entry.member.block_to(member)
      expect(member.entry_favorites.count).to eq 0
      2.times { entry.favorite_by(member) }
      expect(Entry.find(entry.id).favors.count).to eq 0
    end
  
    it "blocked favor do not like" do
      entry.like_by(member)
      expect(member.entry_likes.count).to eq 1
      entry.member.block_to(member)
      expect(member.entry_likes.count).to eq 0
      2.times { entry.like_by(member) }
      expect(Entry.find(entry.id).likers.count).to eq 0
    end
  end

  describe 'google translate' do
    before { entry.update(heading: '題名', body: '最高の音', maker: '', model: nil) }
    it 'attributes' do
      entry.translate_ja_attributes
      expect(entry.heading).to eq 'Title'
      expect(entry.translate_ja_entry.heading).to eq '題名'
      expect(entry.body).to eq 'Best sound'
      expect(entry.translate_ja_entry.body).to eq '最高の音'
    end
  end
end
