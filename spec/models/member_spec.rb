require "rails_helper"

RSpec.describe Member, type: :model do
  let(:member1) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :skip_validate,
                      member_id: member2.id, heading: "entry title")
  }

  it "has many collection_votes" do
    vote = member1.collection_votes.new
    expect(member1.collection_votes.first).to eq vote
  end

  it "has many entry_favorites" do
    entry.favorite_by(member1)
    expect(member1.entry_favorites.first).to eq entry
  end

  it "has many collect entries through votes" do
    member1.collection_votes.create(votable: entry, vote_scope: 1)
    expect(member1.entry_collections.first).to eq entry
    expect(member1.collection_votes.first.vote_scope).to eq 1
  end

  it "has many follow members through votes" do
    member1.follow_votes.create(votable: member2, vote_scope: 2)
    expect(member1.follows.first).to eq member2
    expect(member2.followers.first).to eq member1
  end

  it "has method that follow by member" do
    member1.follow_by(member2)
    expect(member1.followers.first).to eq member2
    expect(member2.follows.first).to eq member1
  end

  it "after deleted have no votes associations" do
    member1.follow_by(member2)
    member2.destroy
    expect(member1.followers.count).to eq 0
  end

  it "follow by whose vote?" do
    member1.follow_by(member2)
    expect(member1.followed?(member2)).to eq true
    expect(member2.followed?(member1)).to eq false
  end

  it "do follow and count cached +1" do
    member1.follow_by(member2)
    expect(Member.find(member1.id).follower_count).to eq 1
  end

  it "invalid duplicate follow by same member" do
    2.times { member1.follow_by(member2) }
    expect(member1.followers.count).to eq 1
    expect(Member.find(member2.id).follow_count).to eq 1
  end

  it "unvote follow" do
    member1.follow_by(member2)
    member1.unfollow_by(member2)
    expect(member2.follows.count).to eq 0
    expect(Member.find(member1.id).follower_count).to eq 0
  end

  it "block follow" do
    member1.follow_by(member2)
    member1.block_to(member2)
    expect(Member.find(member2.id).follow_count).to eq 0
    expect(Member.find(member1.id).follower_count).to eq 0
  end

  it "blocked member do not follow" do
    member1.follow_by(member2)
    expect(Member.find(member1.id).follower_count).to eq 1
    member1.block_to(member2)
    expect(Member.find(member1.id).follower_count).to eq 0
    2.times { member1.follow_by(member2) }
    expect(Member.find(member1.id).follower_count).to eq 0
  end

  it "not follow who self" do
    member1.follow_by(member1)
    expect(Member.find(member1.id).follower_count).to eq 0
  end

  it "initialize member ship when unblock" do
    member1.block_to(member2)
    member1.unblock_to(member2)
    expect(member1.blocked?(member2)).to eq false
  end
end
