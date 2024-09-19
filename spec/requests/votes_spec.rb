require "rails_helper"

RSpec.describe "/votes", type: :request do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :skip_validate,
                      member_id: member.id, heading: "entry title")
  }

  describe "cannot anything with no login" do
    it "when do follow required sign in" do
      post follow_url(follow_id: member2.id)
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end

    it "when do unfollow required sign in" do
      patch unfollow_url(follow_id: member2.id)
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end

    it "when do block member required sign in" do
      patch block_url(follow_id: member2.id)
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end

    it "when do entry collection member required sign in" do
      post entry_collection_url(entry_id: entry.id)
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end
  end

  describe "member doing friendship at login" do
    before { sign_in member }
    it "create follow to other member" do
      post follow_url(follow_id: member2.id)
      expect(response).to redirect_to(profile_path(member2.profile, locale: :en))
    end

    it "do not follow to other member" do
      post follow_url(follow_id: member2.id)
      patch unfollow_url(follow_id: member2.id)
      expect(response).to redirect_to(profile_path(member2.profile, locale: :en))
    end

    it "patch block to other member" do
      post follow_url(follow_id: member2.id)
      patch block_url(follow_id: member2.id)
      expect(response).to redirect_to(profile_path(member2.profile, locale: :en))
    end

    it "unblock and initialize member ship" do
      patch block_url(follow_id: member2.id)
      delete unblock_url(follow_id: member2.id)
      expect(response).to redirect_to(profile_path(member2.profile, locale: :en))
    end
  end

  describe "member doing entry collection" do
    before { sign_in member2 }

    it "entry collection" do
      post entry_collection_url(entry_id: entry.id)
      expect(response).to redirect_to(entry_path(entry.id, locale: :en))
    end

    it "entry uncollection" do
      delete entry_uncollection_url(entry_id: entry.id)
      expect(response).to redirect_to(entry_path(entry.id, locale: :en))
    end

    it "blocked member cannot entry collection" do
      member.block_to(member2)
      post entry_collection_url(entry_id: entry.id)
      expect(response).to redirect_to(entry_path(entry.id, locale: :en))
    end
  end

  describe "bad requests" do
    before { sign_in member }
    it "cannot find params" do
      expect { post follow_url(follow_id: "a") }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cannot access fale routing" do
      expect { post unfollow_url(follow_id: 10) }.
        to raise_error(ActionController::RoutingError)
    end
  end
end
