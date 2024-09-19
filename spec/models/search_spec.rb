require "rails_helper"

RSpec.describe Entry, search: true do
  before do
    htexts = ["fender", "gibson"]
    htexts.each do |heading|
      FactoryBot.create(:entry, :skip_validate, heading: heading)
    end
    Entry.reindex
    Entry.search_index.refresh
  end

  it "searches" do
    expect(Entry.search("fender").first.heading).to eq "fender"
  end

  it "search on fields" do
    expect(Entry.search("gibson", fields: [:heading]).first.heading).to eq "gibson"
  end
end
