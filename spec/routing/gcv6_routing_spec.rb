require "rails_helper"

RSpec.describe "routes for GCV6", type: :routing do
  context "when votes routing" do
    it "routes /votes/follow to the votes controller" do
      expect(post follow_path(1)).
        to route_to controller: "votes", action: "follow", follow_id: "1"
    end

    it "routes /votes/unfollow to the votes controller" do
      expect(patch unfollow_path(1)).
        to route_to controller: "votes", action: "unfollow", follow_id: "1"
    end

    it "routes /votes/block to the votes controller" do
      expect(patch block_path(1)).
        to route_to controller: "votes", action: "block", follow_id: "1"
    end

    it "routes /votes/unblock to the votes controller" do
      expect(delete unblock_path(1)).
        to route_to controller: "votes", action: "unblock", follow_id: "1"
    end

    it "routes /votes/entry_follow to the votes controller" do
      expect(post entry_collection_path(1)).
        to route_to controller: "votes", action: "entry_collection", entry_id: "1"
    end

    it "routes /votes/entry_unfollow to the votes controller" do
      expect(delete entry_uncollection_path(1)).
        to route_to controller: "votes", action: "entry_uncollection", entry_id: "1"
    end

    it "routes /votes/entry_favorite to the votes controller" do
      expect(post entry_favorite_path(1)).
        to route_to controller: "votes", action: "entry_favorite", entry_id: "1"
    end

    it "routes /votes/entry_unfavorite to the votes controller" do
      expect(delete entry_unfavorite_path(1)).
        to route_to controller: "votes", action: "entry_unfavorite", entry_id: "1"
    end

    it "routes /votes/entry_like to the votes controller" do
      expect(post entry_like_path(1)).
        to route_to controller: "votes", action: "entry_like", entry_id: "1"
    end

    it "routes /votes/entry_like to the votes controller" do
      expect(delete entry_unlike_path(1)).
        to route_to controller: "votes", action: "entry_unlike", entry_id: "1"
    end
  end

  context "when entries categories routing" do
    it "routes /entries/categories/electric-solid-guitar" do
      expect(get categories_path("electric_solid_guitar")).
        to route_to controller: "categories", action: "index", category: "electric_solid_guitar"
    end

    it "routes /entries/categories/pedal" do
      expect(get categories_path("pedal")).
        to route_to controller: "categories", action: "index", category: "pedal"
    end

    it "routes /entries/categories/amp" do
      expect(get categories_path("amplifier")).
        to route_to controller: "categories", action: "index", category: "amplifier"
    end

    it "routes /charts/entries_summary" do
      expect(get charts_path("entries_summary_1")).
        to route_to controller: "charts", action: "index", category: "entries_summary_1"
    end
  end

  context "manage resources" do
    it "routes /manages/entry_collections" do
      expect(get manages_entry_collections_path).
        to route_to controller: "manages", action: "entry_collections"
    end
  end
end
