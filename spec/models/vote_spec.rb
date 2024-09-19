require "rails_helper"

RSpec.describe Vote, type: :model do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) { FactoryBot.create(
    :entry, :skip_validate,
    member: member2, heading: "entry title"
    )
  }

  describe "entry counter cache," do
    before { entry.collect_by(member) }

    it "entry collect count" do
      entry.reload
      expect(entry.collector_count).to eq 1
    end

    it "entry uncollect count" do
      entry.uncollect_by(member)
      entry.reload
      expect(entry.collector_count).to eq 0
    end

    it "entry count -1 when member block" do
      member2.block_to(member)
      entry.reload
      expect(entry.collector_count).to eq 0
    end

    it "entry dependent destroy" do
      entry.destroy
      expect(member.entry_collections.count).to eq 0
    end

    it "member dependent destroy" do
      member.destroy
      entry.reload
      expect(entry.collector_count).to eq 0
    end

    it "member2 dependent destroy" do
      member2.destroy
      member.reload
      expect(member.entry_collections.count).to eq 0
    end
  end

  describe "entry favorites count," do
    before { entry.favorite_by(member) }

    it "entry favors count" do
      entry.reload
      expect(entry.favors.count).to eq 1
    end

    it "entry unvavorite count" do
      entry.unfavorite_by(member)
      entry.reload
      expect(entry.favors.count).to eq 0
    end

    it "entry count -1 when member block" do
      member2.block_to(member)
      entry.reload
      expect(entry.favors.count).to eq 0
    end

    it "entry dependent destroy" do
      entry.destroy
      expect(member.entry_favorites.count).to eq 0
    end

    it "member dependent destroy" do
      member.destroy
      entry.reload
      expect(entry.favors.count).to eq 0
    end

    it "member2 dependent destroy" do
      member2.destroy
      member.reload
      expect(member.entry_favorites.count).to eq 0
    end
  end

  describe "follow counter cache," do
    before { member2.follow_by(member) }

    it "follow which follow, follower count" do
      member.reload; member2.reload
      expect(member.follow_count).to eq 1
      expect(member.follower_count).to eq 0
      expect(member2.follow_count).to eq 0
      expect(member2.follower_count).to eq 1
    end

    it "unfollow which follow, follower count" do
      member2.unfollow_by(member)
      member.reload; member2.reload
      expect(member.follow_count).to eq 0
      expect(member.follower_count).to eq 0
      expect(member2.follow_count).to eq 0
      expect(member2.follower_count).to eq 0
    end

    it "block which follow, follower count" do
      member2.block_to(member)
      member.reload; member2.reload
      expect(member.follow_count).to eq 0
      expect(member.follower_count).to eq 0
      expect(member2.follow_count).to eq 0
      expect(member2.follower_count).to eq 0
    end

    it "member dependent destroy" do
      member2.unfollow_by(member)
      member.destroy
      member2.reload
      expect(member2.follow_count).to eq 0
      expect(member2.follower_count).to eq 0
    end

    it "block and destroy which follow, follower count 0" do
      member2.block_to(member)
      member.destroy
      member2.reload
      expect(member2.follow_count).to eq 0
      expect(member2.follower_count).to eq 0
    end

    it "block and destroy which follow, follower count 0" do
      member2.block_to(member)
      member2.destroy
      member.reload
      expect(member.follow_count).to eq 0
      expect(member.follower_count).to eq 0
    end
  end

  describe "notifications for member" do
    it "when entry collected by member" do
      entry.collect_by(member)
      expect(member2.notifications.last.sender.login).to eq member.profile.login
    end

    it "when member2 followed by member" do
      member2.follow_by(member)
      expect(member2.notifications.last.sender.login).to eq member.profile.login
    end

    it "when entry added favorite by member" do
      entry.favorite_by(member)
      expect(member2.notifications.last.params[:heading]).to eq "added favorite entry title"
    end

    it "when entry liked by member" do
      entry.like_by(member)
      expect(member2.notifications.last.params[:heading]).to eq "liked entry title"
    end
  end
end
